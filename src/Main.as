void Main() {
    if (!HAS_PERMISSIONS) {
        _Logging::Error("You don't have enough permissions to use this plugin!", true);

        Meta::Plugin@ self = Meta::ExecutingPlugin();
        Meta::UnloadPlugin(self);
    }

#if !DEPENDENCY_WARRIORMEDALS
    // if plugin was uninstalled, reset settings
    if (S_GoalMedal > Medals::Author || S_MainMedal > Medals::Author) {
        S_GoalMedal = Medals::Author;
        S_MainMedal = Medals::Author;
    }
#endif

    Saves::LoadPlaylists();
    Cache::LoadIdCache();

    NadeoServices::AddAudience("NadeoLiveServices");
    NadeoServices::AddAudience("NadeoServices");

    startnew(MainLoop);
    startnew(PbLoop);

    if (!S_SkipLoad) {
        while (!showMainWindow) {
            yield();
        }

        TM::GetWeeklyShorts();
        TM::GetSeasonalCampaigns();
        TM::GetFavorites();
        TM::GetTOTDMonths();
    }
}

void OnDisabled()  { Cache::StoreMapIds(); }
void OnDestroyed() { Cache::StoreMapIds(); }

[Setting hidden]
bool showMainWindow = true;

void RenderMenu() {
    if (HAS_PERMISSIONS && UI::MenuItem(FULL_NAME, "", showMainWindow)) {
        showMainWindow = !showMainWindow;
    }
}

void Render() {
    if (!HAS_PERMISSIONS || (S_HideWithOP && !UI::IsOverlayShown()) || (S_HideWithGameUI && !UI::IsGameUIVisible())) {
        return;
    }

    UI::RenderMainWindow();

    Renderables::Render();
}

bool held = false;

void OnKeyPress(bool down, VirtualKey key) {
    if (!HAS_PERMISSIONS || playlist.IsEmpty() || TM::IsLoadingMap()) return;

    if (!held && key == S_SwitchKey) {
        playlist.NextMap();
    }

    held = down;
}

void MainLoop() {
    string currentUid = "";
    bool notified = false;

    auto app = cast<CTrackMania>(GetApp());

    while (playlist.IsEmpty() || playlist.currentMap is null) {
        yield();
    }

    while (true) {
        yield();

        if (TM::InEditor() || !TM::InCurrentMap()) {
            sleep(1000);
            continue;
        }

        if (app.RootMap.IdName != currentUid) {
            currentUid = app.RootMap.IdName;
            notified = false;
        }

        if (S_SwitchOnMedal && !notified) {
            int score = TM::GetFinishScore();

            if (score <= -1) {
                sleep(50);
                continue;
            }

            bool inverse = playlist.currentMap.GameMode == GameMode::Stunt;
            int goal = playlist.currentMap.GetMedalScore(S_GoalMedal);

            bool fallback = false;

#if DEPENDENCY_WARRIORMEDALS
            if (S_GoalMedal == Medals::Warrior && !playlist.currentMap.HasWarrior) {
                fallback = true;
                goal = playlist.currentMap.GetMedalScore(Medals::Author);
            }
#endif

            if ((inverse && score >= goal) || (!inverse && score <= goal)) {
                string medalName = fallback ? tostring(Medals(S_GoalMedal - 1)) : tostring(S_GoalMedal);
                UI::ShowNotification(PLUGIN_NAME, "Got the " + medalName + " medal! Loading next map...");
                notified = true;
                sleep(1000);
                playlist.NextMap();
            } else {
                sleep(1000);
            }
        }
    }
}

void PbLoop() {
    auto app = cast<CTrackMania>(GetApp());

    while (true) {
        if (TM::InEditor() || !TM::InMap()) {
            sleep(1000);
            continue;
        }
        
        if (app.Network is null || app.Network.ClientManiaAppPlayground is null) {
            sleep(500);
            continue;
        }

        auto userId = app.UserManagerScript.Users[0].Id;
        auto map = app.RootMap;
        string mapUid = map.IdName;

        bool isStunt = map.MapType == "TrackMania\\TM_Stunt";
        bool isPlatform = map.MapType == "TrackMania\\TM_Platform";

        string mode = "TimeAttack";
        if (isStunt) {
            mode = "Stunt";
        } else if (isPlatform) {
            mode = "Platform";
        }

        auto scoreMgr = app.Network.ClientManiaAppPlayground.ScoreMgr;
        uint score = scoreMgr.Map_GetRecord_v2(userId, mapUid, "PersonalBest", "", mode, "");

        if (score < uint(-1)) {
            if (!PB_UIDS.Exists(mapUid)) {
                PB_UIDS.Set(mapUid, score);
            } else {
                uint oldPb = uint(PB_UIDS[mapUid]);

                if ((isStunt && score > oldPb) || (!isStunt && score < oldPb)) {
                    PB_UIDS[mapUid] = score;
                }
            }
        }

        sleep(500);
    }
}
