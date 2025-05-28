namespace TM {
    void LoadMap(ref@ mapData) {
        Map@ map = cast<Map>(mapData);

        _Logging::Debug("Loading map \"" + map.Name + "\" with map type \"" + map.MapType + "\"");

        if (!Permissions::PlayLocalMap()) {
            _Logging::Error("Missing permission to play local maps. Club / Standard access is required.", true);
            return;
        }

        ClosePauseMenu();

        CTrackMania@ app = cast<CTrackMania>(GetApp());
        app.BackToMainMenu();

        while(!app.ManiaTitleControlScriptAPI.IsReady) {
            yield();
        }

        if (S_Editor) {
            app.ManiaTitleControlScriptAPI.EditMap(map.URL, "", "");
        } else {
            string gameMode;
            TM::ModesFromMapType.Get(map.MapType, gameMode);

            app.ManiaTitleControlScriptAPI.PlayMap(map.URL, gameMode, "");
        }

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
        auto mapsFolder = Fids::GetUserFolder(mainFolder);
        if (mapsFolder is null) {
            _Logging::Error("Failed to find " + mainFolder + " folder in Documents\\Trackmania.", true);
            return null;
        }

        Fids::UpdateTree(mapsFolder);

        auto mapFile = Fids::GetUser(folder + "\\" + fileName);
        if (mapFile is null) {
            _Logging::Error("Failed to find requested map file.", true);
            return null;
        }
        
        auto test = Fids::Preload(mapFile);
        if (test is null) {
            _Logging::Error("Failed to preload " + fileName, true);
            return null;
        }
        
        auto map = cast<CGameCtnChallenge>(test);
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
            _Logging::Error("Failed to find a map with UUID " + mapUid, true);
            _Logging::Error("Failed to get file URL from UUID: Error " + res.ErrorCode + " - " + res.ErrorDescription);
            return null;
        }

        CNadeoServicesMap@ map = res.Map;
        _Logging::Info("Found URL " + map.FileUrl + " from UUID " + mapUid);
        print(map.AuthorDisplayName);
        print(map.AuthorWebServicesUserId);
        print(map.AuthorAccountId);

        return map;
    }
}
