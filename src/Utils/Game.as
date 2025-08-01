namespace TM {
    bool loadingMap;

    const uint COOLDOWN = 5000;

    void LoadMap(ref@ mapData) {
        try {
            Map@ map = cast<Map>(mapData);

            if (IsLoadingMap()) {
                // A map is already loading, ignore
                return;
            }

            _Logging::Debug("Loading map \"" + map.Name + "\" with map type \"" + map.MapType + "\"");

            if (!Permissions::PlayLocalMap()) {
                _Logging::Error("Missing permission to play local maps. Club / Standard access is required.", true);
                return;
            }

            loadingMap = true;

            ClosePauseMenu();

            CTrackMania@ app = cast<CTrackMania>(GetApp());
            app.BackToMainMenu();

            while (!app.ManiaTitleControlScriptAPI.IsReady) {
                yield();
            }

            if (S_Editor) {
                app.ManiaTitleControlScriptAPI.EditMap(map.Url, "", "");
            } else {
                string gameMode;
                TM::ModesFromMapType.Get(map.MapType, gameMode);

                app.ManiaTitleControlScriptAPI.PlayMap(map.Url, gameMode, "");
            }

            const uint start = Time::Now;

            while (Time::Now < start + COOLDOWN || IsLoadingScreen()) {
                yield();
            }

            loadingMap = false;
            @playlist.currentMap = map;
        } catch {
            _Logging::Error("An error occurred while loading the map", true);
            loadingMap = false;
        }
    }

    bool InMap() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        return app.RootMap !is null;
    }

    bool InEditor() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        return app.Editor !is null;
    }

    bool InCurrentMap() {
        if (playlist.currentMap is null) {
            return false;
        }

        CTrackMania@ app = cast<CTrackMania>(GetApp());

        if (app.RootMap is null || app.RootMap.MapInfo.MapUid == "") {
            return false;
        }

        return app.RootMap.MapInfo.MapUid.ToLower() == playlist.currentMap.Uid.ToLower();
    }

    void ClosePauseMenu() {
        if (IsPauseMenuDisplayed()) {
            CSmArenaClient@ playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);

            if (playground !is null) {
                playground.Interface.ManialinkScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Resume);
            }
        }
    }

    bool IsPauseMenuDisplayed() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        return app.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed;
    }

    CGameCtnChallenge@ GetMapFromFid(const string &in fileName, const string &in folder = "Maps\\Temp") {
        _Logging::Debug("Getting map \"" + fileName + "\" from \"" + folder + "\" folder.");

        string mainFolder = folder.Split("\\")[0];
        CSystemFidsFolder@ mapsFolder = Fids::GetUserFolder(mainFolder);
        if (mapsFolder is null) {
            _Logging::Error("Failed to find " + mainFolder + " folder in Documents\\Trackmania.", true);
            return null;
        }

        Fids::UpdateTree(mapsFolder);

        CSystemFidFile@ mapFile = Fids::GetUser(folder + "\\" + fileName);
        if (mapFile is null) {
            _Logging::Error("Failed to find requested map file.", true);
            return null;
        }
        
        CMwNod@ nod = Fids::Preload(mapFile);
        if (nod is null) {
            _Logging::Error("Failed to preload " + fileName, true);
            return null;
        }
        
        CGameCtnChallenge@ map = cast<CGameCtnChallenge>(nod);
        if (map is null) {
            _Logging::Error("Failed to cast " + fileName + " to its class.", true);
            _Logging::Warn("Casting map to CGameCtnChallenge failed. File might not be a valid GBX map file");
            return null;
        }

        return map;
    }

    Map@ GetMapFromUid(const string &in mapUid) {
        _Logging::Debug("Getting map from UID " + mapUid);

        Map@ cachedMap = Cache::GetMap(mapUid);

        if (cachedMap !is null) {
            return cachedMap;
        }

        auto app = cast<CGameManiaPlanet>(GetApp());
        auto menu = app.MenuManager.MenuCustom_CurrentManiaApp;
        auto userId = menu.UserMgr.Users[0].Id;
        auto res = menu.DataFileMgr.Map_NadeoServices_GetFromUid(userId, mapUid);
        
        WaitAndClearTaskLater(res, menu.DataFileMgr);

        if (!res.HasSucceeded || res.HasFailed) {
            _Logging::Error("Failed to find a map with UID " + mapUid, true);
            _Logging::Error("Failed to get file URL from UID: Error " + res.ErrorCode + " - " + res.ErrorDescription);
            return null;
        }

        Map@ map = Map(res.Map);
        _Logging::Info("Found URL " + map.Url + " from UID " + mapUid);

        return map;
    }

    MwFastBuffer<CNadeoServicesMap@> GetMultipleMapsFromUids(array<string> uids) {
        _Logging::Debug("Getting " + uids.Length + " maps from UID.");
        _Logging::Debug("UIDs: " + string::Join(uids, ", "));

        MwFastBuffer<wstring> bufferUids;

        for (uint i = 0; i < uids.Length; i++) {
            bufferUids.Add(uids[i]);
        }

        auto app = cast<CGameManiaPlanet>(GetApp());
        auto menu = app.MenuManager.MenuCustom_CurrentManiaApp;
        auto userId = menu.UserMgr.Users[0].Id;
        auto res = menu.DataFileMgr.Map_NadeoServices_GetListFromUid(userId, bufferUids);
        
        WaitAndClearTaskLater(res, menu.DataFileMgr);

        if (!res.HasSucceeded || res.HasFailed) {
            _Logging::Error("Failed to get maps from UIDs", true);
            _Logging::Error("Failed to get maps from UIDs: Error " + res.ErrorCode + " - " + res.ErrorDescription);
            return MwFastBuffer<CNadeoServicesMap@>();
        }

        _Logging::Info("Found " + res.MapList.Length + " maps from " + uids.Length + " UIDs.");
        return res.MapList;
    }

    bool IsLoadingScreen() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        auto pgCSApi = app.Network.PlaygroundClientScriptAPI;

        if (pgCSApi !is null && pgCSApi.IsLoadingScreen) {
            return true;
        }

        auto pg = app.PlaygroundScript;
        if (pg is null) return false;

        auto uiManager = pg.UIManager;
        if (uiManager !is null && uiManager.HoldLoadingScreen) {
            return true;
        }

        return false;
    }

    bool IsLoadingMap() {
        return loadingMap;
    }

    void GetWeeklyShorts() {
        if (!WEEKLY_SHORTS.IsEmpty()) {
            return;
        }

        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            yield();
        }

        string url = NadeoServices::BaseURLLive() + "/api/campaign/weekly-shorts?length=500&offset=0";

        auto req = NadeoServices::Get("NadeoLiveServices", url);
        req.Start();

        while (!req.Finished()) {
            yield();
        }

        int resCode = req.ResponseCode();
        Json::Value@ json = req.Json();

        _Logging::Trace("[GetWeeklyShorts] Response code: " + resCode);
        _Logging::Trace("[GetWeeklyShorts] JSON: " + Json::Write(json, true));

        if (resCode >= 400 || json.GetType() != Json::Type::Object || !json.HasKey("campaignList")) {
            _Logging::Error("Failed to get weekly shorts weeks from Nadeo Services");
            return;
        } else if (json["campaignList"].Length == 0) {
            _Logging::Error("Weekly shorts endpoint returned 0 weeks");
            return;
        }

        Json::Value@ weeks = json["campaignList"];

        for (uint i = 0; i < weeks.Length; i++) {
            Campaign@ week = Campaign(weeks[i]);
            WEEKLY_SHORTS.InsertLast(week);
        }

        _Logging::Debug("Loaded " + weeks.Length + " weekly shorts weeks.");
    }

    void GetSeasonalCampaigns() {
        if (!SEASONAL_CAMPAIGNS.IsEmpty()) {
            return;
        }

        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            yield();
        }

        string url = NadeoServices::BaseURLLive() + "/api/campaign/official?length=500&offset=0";

        auto req = NadeoServices::Get("NadeoLiveServices", url);
        req.Start();

        while (!req.Finished()) {
            yield();
        }

        int resCode = req.ResponseCode();
        Json::Value@ json = req.Json();

        _Logging::Trace("[GetSeasonalCampaigns] Response code: " + resCode);
        _Logging::Trace("[GetSeasonalCampaigns] JSON: " + Json::Write(json, true));

        if (resCode >= 400 || json.GetType() != Json::Type::Object || !json.HasKey("campaignList")) {
            _Logging::Error("Failed to get seasonal campaigns from Nadeo Services");
            return;
        } else if (json["campaignList"].Length == 0) {
            _Logging::Error("Seasonal campaigns endpoint returned 0 campaigns");
            return;
        }

        Json::Value@ campaigns = json["campaignList"];

        for (uint i = 0; i < campaigns.Length; i++) {
            Campaign@ season = Campaign(campaigns[i]);
            SEASONAL_CAMPAIGNS.InsertLast(season);
        }

        _Logging::Debug("Loaded " + campaigns.Length + " seasonal campaigns.");
    }

    void GetFavorites() {
        if (!FAVORITES.IsEmpty()) {
            return;
        }

        auto app = cast<CGameManiaPlanet>(GetApp());
        auto menu = app.MenuManager.MenuCustom_CurrentManiaApp;
        auto userId = menu.UserMgr.Users[0].Id;
        auto res = menu.DataFileMgr.Map_NadeoServices_GetFavoriteList(userId, MwFastBuffer<wstring>(), true, false, true, false);
        
        WaitAndClearTaskLater(res, menu.DataFileMgr);

        if (!res.HasSucceeded || res.HasFailed) {
            _Logging::Error("Failed to get favorite maps", true);
            _Logging::Error("Failed to get favorite maps: Error " + res.ErrorCode + " - " + res.ErrorDescription);
            return;
        }

        _Logging::Info("Found " + res.MapList.Length + " maps in favorites.");

        MwFastBuffer<CNadeoServicesMap@> favoriteMaps = res.MapList;

        for (uint i = 0; i < favoriteMaps.Length; i++) {
            Map@ map = Map(favoriteMaps[i]);
            FAVORITES.InsertLast(map);
        }

        _Logging::Debug("Loaded " + favoriteMaps.Length + " favorites.");
    }

    void GetTOTDMonths() {
        if (!TOTD_MONTHS.IsEmpty()) {
            return;
        }

        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            yield();
        }

        string url = NadeoServices::BaseURLLive() + "/api/token/campaign/month?offset=0&length=250";

        auto req = NadeoServices::Get("NadeoLiveServices", url);
        req.Start();

        while (!req.Finished()) {
            yield();
        }

        int resCode = req.ResponseCode();
        Json::Value@ json = req.Json();

        _Logging::Trace("[GetTOTDMonths] Response code: " + resCode);
        //_Logging::Trace("[GetTOTDMonths] JSON: " + Json::Write(json, true));

        if (resCode >= 400 || json.GetType() != Json::Type::Object || !json.HasKey("monthList")) {
            _Logging::Error("Failed to get TOTD months from Nadeo Services");
            return;
        } else if (json["monthList"].Length == 0) {
            _Logging::Error("TOTD endpoint returned 0 months");
            return;
        }

        Json::Value@ monthList = json["monthList"];

        for (uint i = 0; i < monthList.Length; i++) {
            Json::Value@ data = monthList[i];
            
            if (data["days"].Length == 0) {
                // Month doesn't have any maps
                continue;
            }

            TOTDMonth@ month = TOTDMonth(monthList[i]);
            TOTD_MONTHS.InsertLast(month);
        }

        _Logging::Debug("Loaded " + TOTD_MONTHS.Length + " TOTD months.");
    }

    Campaign@ GetClubCampaign(int clubId, int campaignId) {
        if (!Permissions::PlayPublicClubCampaign()) {
            _Logging::Error("Missing permission to play club campaigns!", true);
            return null;
        }

        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            yield();
        }

        string url = NadeoServices::BaseURLLive() + "/api/token/club/" + clubId + "/campaign/" + campaignId;

        _Logging::Debug("Club campaign API request: " + url);

        auto req = NadeoServices::Get("NadeoLiveServices", url);
        req.Start();

        while (!req.Finished()) {
            yield();
        }

        int resCode = req.ResponseCode();
        Json::Value@ json = req.Json();

        _Logging::Trace("[GetClubCampaign] Response code: " + resCode);
        _Logging::Trace("[GetClubCampaign] JSON: " + Json::Write(json, true));

        if (json.GetType() == Json::Type::Array) {
            if (json[0] == "activity:error-notFound") {
                _Logging::Error("Failed to get club campaign: A club or campaign with that ID doesn't exist!", true);
                return null;
            }

            _Logging::Error("Failed to get club campaign: " + string(json[0]), true);
            return null;
        } else if (resCode >= 400 || json.GetType() != Json::Type::Object || !json.HasKey("campaign")) {
            _Logging::Error("Failed to get club campaign from Nadeo Services");
            return null;
        }

        Json::Value@ data = json["campaign"];

        _Logging::Info("Found club campaign " + string(data["name"]) + " from the club " + string(json["clubName"]));

        return Campaign(data);
    }

    uint MAX_ATTEMPTS = 5;
    uint LENGTH = 250;

    int GetCampaignIdFromActivity(int clubId, int activityId) {
        if (!Permissions::PlayPublicClubCampaign()) {
            _Logging::Error("Missing permission to play club campaigns!", true);
            return -1;
        }

        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            yield();
        }

        for (uint i = 0; i < MAX_ATTEMPTS; i++) {
            uint offset = LENGTH * i;
            uint currentPage = i + 1;

            string url = NadeoServices::BaseURLLive() + "/api/token/club/" + clubId + "/activity?length=" + LENGTH + "&offset=" + offset + "&active=true";

            _Logging::Debug("Club activities API request: " + url);

            auto req = NadeoServices::Get("NadeoLiveServices", url);
            req.Start();

            while (!req.Finished()) {
                yield();
            }

            int resCode = req.ResponseCode();
            Json::Value@ json = req.Json();

            _Logging::Trace("[GetCampaignIdFromActivity] Response code: " + resCode);

            if (resCode >= 400 || json.GetType() != Json::Type::Object || !json.HasKey("activityList")) {
                _Logging::Error("Failed to get club campaign ID from Nadeo Services");
                return -1;
            }

            Json::Value@ activities = json["activityList"];

            for (uint a = 0; a < activities.Length; a++) {
                Json::Value@ activity = activities[a];

                int id = activity["id"];
                string type = activity["activityType"];

                if (id == activityId && type == "campaign") {
                    return activity["campaignId"];
                }
            }

            uint items = json["itemCount"];
            uint maxPages = json["maxPage"];

            if (items < LENGTH || maxPages == currentPage) {
                // We reached the end
                return -1;
            }

            if (currentPage < MAX_ATTEMPTS) {
                // Limit requests to 1 per second
                sleep(1000);
            }
        }

        return -1;
    }

    array<uint> royalTimes = { 0, 0, 0, 0 };

    int GetFinishScore() {
        if (!TM::InCurrentMap()) {
            return -1;
        }

        auto app = cast<CTrackMania>(GetApp());
        int score = -1;

        CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);
        CSmArenaRulesMode@ script = cast<CSmArenaRulesMode>(app.PlaygroundScript);

        if (playground !is null && script !is null && playground.GameTerminals.Length > 0) {
            CSmPlayer@ player = cast<CSmPlayer>(playground.GameTerminals[0].ControlledPlayer);

            if (player is null) {
                return -1;
            }

            auto seq = playground.GameTerminals[0].UISequence_Current;

            if (seq == SGamePlaygroundUIConfig::EUISequence::Finish || seq == SGamePlaygroundUIConfig::EUISequence::UIInteraction) {
                CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
                auto ghost = script.Ghost_RetrieveFromPlayer(playerScriptAPI);

                if (ghost !is null) {
                    switch (playlist.currentMap.GameMode) {
                        case GameMode::Stunt:
                            score = ghost.Result.StuntsScore;
                            break;
                        case GameMode::Platform:
                            score = ghost.Result.NbRespawns;
                            break;
                        case GameMode::Race:
                        case GameMode::Royal:
                        default:
                            if (ghost.Result.Time > 0 && ghost.Result.Time < uint(-1)) {
                                score = ghost.Result.Time;
                            }
                            break;
                    }

                    script.DataFileMgr.Ghost_Release(ghost.Id);

                    // from the Random Altered Campaign Challenge plugin https://openplanet.dev/plugin/randomalteredcampaign
                    // Credit to ArEyeses for the code
                    if (playlist.currentMap.GameMode == GameMode::Royal) {
                        uint resIndex = player.CurrentLaunchedRespawnLandmarkIndex;

                        if (resIndex >= 0 && resIndex < playground.Arena.MapLandmarks.Length) {
                            uint section = playground.Arena.MapLandmarks[resIndex].Order;

                            if (section == 5) {
                                return royalTimes[0] + royalTimes[1] + royalTimes[2] + royalTimes[3] + score;
                            }

                            royalTimes[section - 1] = score;

                            // Reset section times from previous runs
                            for (uint i = section; i < royalTimes.Length; i++) {
                                royalTimes[i] = 0;
                            }

                            return -1;
                        }

                        return -1;
                    }
                }
            }
        }

        return score;
    }

    dictionary newPbs;

    void GetAccountPbs() {
        while (!NadeoServices::IsAuthenticated("NadeoServices")) {
            yield();
        }

        string userId = NadeoServices::GetAccountID();
        uint offset = 0;
        bool stunt = true;
        bool platform = true;

        while (true) {
            string url = NadeoServices::BaseURLCore() + "/v2/accounts/" + userId + "/mapRecords?offset=" + offset;

            if (stunt) {
                url += "&gameMode=Stunt";
            } else if (platform) {
                url += "&gameMode=Platform";
            }

            _Logging::Debug("Account PBs API request: " + url);

            auto req = NadeoServices::Get("NadeoServices", url);
            req.Start();

            while (!req.Finished()) {
                yield();
            }

            int resCode = req.ResponseCode();
            Json::Value@ json = req.Json();

            _Logging::Trace("[GetAccountPbs] Response code: " + resCode);

            if (resCode >= 400 || json.GetType() != Json::Type::Array) {
                _Logging::Error("Failed to get account PBs from Nadeo Services");
                return;
            }

            string modeStr = stunt ? "Stunt" : platform ? "Platform" : "Race";
            _Logging::Debug("Found " + json.Length + " " + modeStr + " records");

            for (uint i = 0; i < json.Length; i++) {
                Json::Value@ record = json[i];

                string mapId = record["mapId"];
                string mode = record["gameMode"];

                int score;

                if (mode == "Stunt") {
                    score = record["recordScore"]["score"];
                } else if (mode == "Platform") {
                    score = record["recordScore"]["respawnCount"];
                } else {
                    score = record["recordScore"]["time"];
                }

                if (score >= 0 && !newPbs.Exists(mapId)) {
                    newPbs.Set(mapId, score);
                }
            }

            if (stunt) {
                stunt = false;
                sleep(1000);
                continue;
            }

            if (platform) {
                platform = false;
                sleep(1000);
                continue;
            }

            // records endpoint returns 1000 records per request
            if (json.Length < 1000) {
                break;
            }

            offset += 1000;

            sleep(1000);
        }

        GetMapUids();
    }

    void GetMapUids() {
        while (!NadeoServices::IsAuthenticated("NadeoServices")) {
            yield();
        }

        array<string> mapIds = newPbs.GetKeys();
        uint index = 0;

        while (index < mapIds.Length) {
            array<string> idlist;

            for (uint i = index; i < mapIds.Length; i++) {
                idlist.InsertLast(mapIds[i]);

                if (idlist.Length >= 200) {
                    break;
                }
            }

            string url = NadeoServices::BaseURLCore() + "/maps/?mapIdList=" + string::Join(idlist, ",");

            _Logging::Debug("Map Info API request: " + url);

            auto req = NadeoServices::Get("NadeoServices", url);
            req.Start();

            while (!req.Finished()) {
                yield();
            }

            int resCode = req.ResponseCode();
            Json::Value@ json = req.Json();

            _Logging::Trace("[GetMapUids] Response code: " + resCode);

            if (resCode >= 400 || json.GetType() != Json::Type::Array) {
                _Logging::Error("Failed to get map IDs from Nadeo Services");
                return;
            }

            for (uint i = 0; i < json.Length; i++) {
                Json::Value@ map = json[i];

                string mapId = map["mapId"];
                string mapUid = map["mapUid"];

                if (newPbs.Exists(mapId)) {
                    PB_UIDS.Set(mapUid, int(newPbs[mapId]));
                }
            }

            index += idlist.Length;
            sleep(1000);
        }
    }
}
