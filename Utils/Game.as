namespace TM {
    bool loadingMap;

    void LoadMap(ref@ mapData) {
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
            app.ManiaTitleControlScriptAPI.EditMap(map.URL, "", "");
        } else {
            string gameMode;
            TM::ModesFromMapType.Get(map.MapType, gameMode);

            app.ManiaTitleControlScriptAPI.PlayMap(map.URL, gameMode, "");
        }

        while (IsLoadingScreen()) {
            yield();
        }

        loadingMap = false;
        @playlist.currentMap = map;
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

    CNadeoServicesMap@ GetMapFromUid(const string &in mapUid) {
        _Logging::Debug("Getting map from UID " + mapUid);

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

        CNadeoServicesMap@ map = res.Map;
        _Logging::Info("Found URL " + map.FileUrl + " from UID " + mapUid);

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
}
