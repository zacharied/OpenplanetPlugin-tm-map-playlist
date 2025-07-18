void Main() {
    if (!HAS_PERMISSIONS) {
        _Logging::Error("You don't have enough permissions to use this plugin!", true);

        Meta::Plugin@ self = Meta::ExecutingPlugin();
        Meta::UnloadPlugin(self);
    }

    Saves::LoadPlaylists();

    NadeoServices::AddAudience("NadeoLiveServices");

    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        yield();
    }

    if (!S_SkipLoad) {
        TM::GetWeeklyShorts();
        TM::GetSeasonalCampaigns();
        TM::GetFavorites();
        TM::GetTOTDMonths();
    }

    startnew(MainLoop);
}

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
        // Don't do anything yet
        yield();
    }

    while (true) {
        yield();

        if (TM::InEditor() || !TM::InCurrentMap()) {
            sleep(1000);
            continue;
        }

        if (app.RootMap.Id.GetName() != currentUid) {
            currentUid = app.RootMap.Id.GetName();
            notified = false;
        }

        if (S_SwitchOnMedal && !notified) {
            int score = TM::GetFinishScore();

            if (score <= -1) {
                sleep(50);
                continue;
            }

            bool inverse = playlist.currentMap.GameMode == GameMode::Stunt;
            int goal = playlist.currentMap.GetMedal(S_GoalMedal);

            if ((inverse && score >= goal) || (!inverse && score <= goal)) {
                UI::ShowNotification(PLUGIN_NAME, "Got the " + tostring(S_GoalMedal) + " medal! Loading next map...");
                notified = true;
                sleep(1000);
                playlist.NextMap();
            } else {
                sleep(1000);
            }
        }
    }
}
