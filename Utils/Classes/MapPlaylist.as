class MapPlaylist {
    array<Map@> Maps;
    Map@ currentMap;
    string Name;

    uint get_Length() {
        return Maps.Length;
    }

    Map@ opIndex(uint i) {
        return Maps[i];
    }

    bool IsEmpty() {
        return Maps.IsEmpty();
    }

    void Clear() {
        _Logging::Debug("Clearing playlist...");

        Maps.RemoveRange(0, Maps.Length);
        @currentMap = null;
    }

    void PlayMap(Map@ map) {
        startnew(CoroutineFuncUserdata(TM::LoadMap), map);
    }

    void NextMap() {
        if (Maps.IsEmpty()) return;

        try {
            if (currentMap is null) {
                startnew(CoroutineFuncUserdata(TM::LoadMap), Maps[0]);
            } else {
                int index = Maps.FindByRef(currentMap);

                if (index == int(Maps.Length - 1)) {
                    // reached last item
                    if (S_Loop) {
                        startnew(CoroutineFuncUserdata(TM::LoadMap), Maps[0]);
                    }
                } else {
                    startnew(CoroutineFuncUserdata(TM::LoadMap), Maps[index + 1]);
                }
            }
        } catch {
            _Logging::Error("An error occurred while switching maps: " + getExceptionInfo(), true);
        }
    }

    void DeleteMap(Map@ map) {
        _Logging::Debug("Deleting map " + map.toString());

        try {
            if (Maps.IsEmpty()) return;

            int index = Maps.FindByRef(map);

            if (index == -1) {
                _Logging::Error("Failed to find map " + map.toString() + " index while deleting it from playlist!");
                return;
            }

            if (currentMap !is null && currentMap == map) {
                if (index == int(Maps.Length - 1)) {
                    if (Maps.Length > 1 && S_Loop) {
                        @currentMap = Maps[0];
                    } else {
                        @currentMap = null;
                    }
                } else {
                    @currentMap = Maps[index + 1];
                }
            }

            Maps.RemoveAt(index);
        } catch {
            _Logging::Error("An error occurred while deleting a map: " + getExceptionInfo(), true);
            _Logging::Warn("Failed to delete map \"" + map.toString() + "\"");
        }
    }

    void ShiftMap(Map@ map, bool down = false) {
        try {
            int index = Maps.FindByRef(map);

            if (index == -1) {
                _Logging::Error("Failed to find map " + map.toString() + " index while moving it in playlist!");
                return;
            }

            _Logging::Debug("Shifting map " + map.toString() + " in playlist.");

            Maps.RemoveAt(index);

            // In a table, the first elements are up
            if (down) {
                Maps.InsertAt(index + 1, map);
            } else {
                Maps.InsertAt(index - 1, map);
            }
        } catch {
            _Logging::Error("An error occurred while moving a map in the playlist: " + getExceptionInfo(), true);
            _Logging::Warn("Failed to shift map \"" + map.toString() + "\"");
        }
    }

    // Durstenfeld shuffle
    void Randomize() {
        try {
            _Logging::Debug("Randomizing playlist. Playlist length: " + Maps.Length);
            array<Map@> shuffled = Maps;

            for (int i = shuffled.Length - 1; i > 0; i--) {
                int j = Math::Rand(0, i + 1);
                Map@ temp = shuffled[i];
                @shuffled[i] = shuffled[j];
                @shuffled[j] = temp;
            }

            this.Maps = shuffled;
        } catch {
            _Logging::Error("An error occurred while randomizing the playlist: " + getExceptionInfo(), true);
        }
    }

    void Load(Json::Value@ json) {
        if (json.GetType() != Json::Type::Object) {
            _Logging::Error("Failed to load playlist from JSON! Expected a JSON object, received " + tostring(json.GetType()), true);
            return;
        }

        Clear();

        _Logging::Debug("Loading playlist \"" + string(json["Name"]) + "\" from JSON");
        _Logging::Debug(Json::Write(json, true));

        Name = json["Name"];

        for (uint i = 0; i < json["Maps"].Length; i++) {
            Json::Value@ map = json["Maps"][i];

            if (map.GetType() != Json::Type::Object) {
                _Logging::Warn("Invalid JSON type for playlist map. Ignoring...");
                continue;
            }

            Maps.InsertLast(Map(map));
        }

        _Logging::Info("Succesfully loaded playlist \"" + string(json["Name"]) + "\" from JSON");
        UI::ShowNotification(FULL_NAME, "Loaded playlist \"" + string(json["Name"]) + "\"!");
    }

    Json::Value@ ToJson() {
        _Logging::Trace("Converting playlist to JSON");

        Json::Value json = Json::Object();
        json["Maps"] = Json::Array();
        json["Timestamp"] = Time::Stamp;

        try {
            for (uint i = 0; i < Maps.Length; i++) {
                Map@ map = Maps[i];
                json["Maps"].Add(map.ToJson());
            }

            return json;
        } catch {
            _Logging::Error("An error occurred while converting the playlist to a JSON: " + getExceptionInfo(), true);
            return null;
        }
    }

    // Addition methods

    void Add(Source source, const string &in field) {
        switch (source) {
            case Source::TMX_Map_ID:
                startnew(CoroutineFuncUserdataString(AddFromTMXId), field);
                break;
            case Source::TMX_Mappack_ID:
                startnew(CoroutineFuncUserdataString(AddMappack), field);
                break;
            case Source::UUID:
                startnew(CoroutineFuncUserdataString(AddFromUuid), field);
                break;
            case Source::File:
                startnew(CoroutineFuncUserdataString(AddFromFile), field.Replace("/", "\\"));
                break;
            case Source::Folder:
                startnew(CoroutineFuncUserdataString(AddFolder), field.Replace("/", "\\"));
                break;
            case Source::URL:
            default:
                startnew(CoroutineFuncUserdataString(AddFromUrl), field);
                break;
        }
    }

    void Add(Source source, Campaign@ campaign) {
        startnew(CoroutineFuncUserdata(AddCampaign), campaign);
    }

    void AddMap(Map@ map) {
        _Logging::Debug("Adding " + map.toString() + " to the playlist");

        Maps.InsertLast(map);
    }

    void AddCampaign(ref@ campRef) {
        Campaign@ campaign = cast<Campaign>(campRef);

        _Logging::Debug("Adding the " + campaign.Name + " campaign to the playlist");

        campaign.LoadMapData();

        while (!campaign.LoadedData) {
            yield();
        }

        for (uint i = 0; i < campaign.MapList.Length; i++) {
            Map@ map = campaign.MapList[i];
            Maps.InsertLast(map);
        }
    }

    void AddFromUuid(const string &in uuid) {
        if (uuid.Length < 25 || uuid.Length > 27) {
            _Logging::Error("Invalid UUID " + uuid + " received. Ignoring...", true);
            return;
        }

        _Logging::Debug("Adding map with UID \"" + uuid + "\" to playlist");

        CNadeoServicesMap@ result = TM::GetMapFromUid(uuid);

        if (result !is null) {
            Maps.InsertLast(Map(result));
            _Logging::Info("Added map with UID \"" + uuid + "\" to the playlist!");
        }
    }

    void AddFromTMXId(const string &in mapId) {
        _Logging::Debug("Adding TMX map with ID #" + mapId);

        string reqUrl = "https://trackmania.exchange/api/maps?count=100&fields=" + MAP_FIELDS + "&id=" + mapId;

        try {
            Json::Value json = API::GetAsync(reqUrl);

            if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                _Logging::Error("Something went wrong while fetching map with ID #" + mapId, true);
                _Logging::Debug(Json::Write(json));

                return;
            } else if (json["Results"].Length == 0) {
                _Logging::Error("Failed to find a map with ID #" + mapId + ". Map might be private or deleted.", true);
                return;
            }

            MXMapInfo@ info = MXMapInfo(json["Results"][0]);
            Maps.InsertLast(Map(info));

            _Logging::Info("Added TMX map with ID #" + mapId + " to the playlist!");
        } catch {
            _Logging::Error("An error occurred while fetching map with ID #" + mapId + "from TMX: " + getExceptionInfo(), true);
        }
    }

    void AddMappack(const string &in id) {
        _Logging::Debug("Adding TMX mappack with ID #" + id);

        string reqUrl = "https://trackmania.exchange/api/maps?count=100&fields=" + MAP_FIELDS + "&mappackid=" + id;

        try {
            Json::Value json = API::GetAsync(reqUrl);

            if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                _Logging::Error("Something went wrong while fetching maps from mappack ID #" + id, true);
                _Logging::Debug(Json::Write(json));

                return;
            } else if (json["Results"].Length == 0) {
                _Logging::Error("Found 0 maps for mappack ID #" + id + ". Mappack might not exist or is empty", true);
                return;
            }

            Json::Value@ items = json["Results"];

            for (uint i = 0; i < items.Length; i++) {
                MXMapInfo@ info = MXMapInfo(items[i]);
                Maps.InsertLast(Map(info));
            }

            _Logging::Info("Added " + items.Length + " maps to the playlist!");

            if (bool(json["More"])) {
                _Logging::Warn("Mappack has more than 100 maps! Added first 100 to the playlist", true);
            }
        } catch {
            _Logging::Error("An error occurred while fetching the maps from mappack ID #" + id + ": " + getExceptionInfo(), true);
        }
    }

    void AddFromFile(const string &in path) {
        try {
            if (!IO::FileExists(path)) {
                _Logging::Warn("Failed to find file in provided path. Make sure to use an absolute path!", true);
                return;
            } else if (!path.ToLower().EndsWith(".map.gbx")) {
                _Logging::Warn("The path \"" + path + "\" doesn't correspond to a GBX map file!", true);
                return;
            }

            _Logging::Debug("Adding map from file path " + path);

            const string fileName = Path::GetFileName(path);

            CGameCtnChallenge@ cmap;

            if (path.StartsWith(USER_FOLDER)) {
                // No need to copy file
                _Logging::Debug("Map file \"" + fileName + "\" is in user folder. Skipping copy...");

                string folder = Path::GetDirectoryName(path.Replace(USER_FOLDER, ""));

                if (folder == "") {
                    return;
                } else if (folder.EndsWith("\\")) {
                    folder = folder.SubStr(0, folder.Length - 1);
                }

                @cmap = TM::GetMapFromFid(fileName, folder);
            } else {
                // copy
                _Logging::Debug("Map file " + fileName + " isn't in user folder. Copying...");

                if (!IO::FolderExists(TEMP_MAP_FOLDER)) {
                    IO::CreateFolder(TEMP_MAP_FOLDER);
                }
                
                string newPath = TEMP_MAP_FOLDER + fileName;

                IO::Copy(path, newPath);
                @cmap = TM::GetMapFromFid(fileName);
                IO::Delete(newPath);
            }

            if (cmap !is null) {
                Maps.InsertLast(Map(cmap, path));
                _Logging::Info("Added map file to the playlist!");
            }
        } catch {
            _Logging::Error("An error occurred while adding a map from path \"" + path + "\": " + getExceptionInfo(), true);
        }
    }

    int regexFlags = Regex::Flags::ECMAScript | Regex::Flags::CaseInsensitive;

    void AddFromUrl(const string &in str) {
        _Logging::Debug("Adding URL \"" + str + "\"");

        if (Regex::IsMatch(str, "\\d{1,6}")) {
            AddFromTMXId(str);
        } else if (Regex::Contains(str, "https:\\/\\/trackmania\\.exchange\\/(mapgbx|maps\\/download|tracks|tracks\\/view|maps|maps\\/view|s\\/tr|mapshow)\\/\\d{1,6}", regexFlags)) {
            array<string> id = Regex::Search(str, "\\/(\\d{1,6})");

            if (!id.IsEmpty()) {
                AddFromTMXId(id[1]);
            }
        } else if (Regex::Contains(str, "https:\\/\\/trackmania\\.exchange\\/(mappack|mappack\\/view|s\\/m|mappackshow)\\/\\d{1,6}", regexFlags)) {
            array<string> id = Regex::Search(str, "\\/(\\d{1,6})");

            if (!id.IsEmpty()) {
                AddMappack(id[1]);
            }
        } else if (Regex::Contains(str, "https:\\/\\/trackmania\\.io\\/.*?\\/\\w{25,27}\\/?$", regexFlags)) {
            array<string> uid = Regex::Search(str, "(\\w{25,27})");

            if (!uid.IsEmpty()) {
                AddFromUuid(uid[1]);
            }
        } else if (Regex::Contains(str, "https:\\/\\/trackmania\\.com\\/tracks\\/\\w{25,27}\\/?", regexFlags)) {
            array<string> uid = Regex::Search(str, "(\\w{25,27})");

            if (!uid.IsEmpty()) {
                AddFromUuid(uid[1]);
            }
        } else if (Regex::Contains(str, "https:\\/\\/trackmania\\.io\\/#\\/campaigns\\/.*?\\/\\d{1,6}\\/?$", regexFlags)) {
            array<string> matches = Regex::Search(str, "campaigns\\/(.*?)\\/(\\d{1,6})");
            int clubId;
            int campaignId;

            if (!matches.IsEmpty() && Text::TryParseInt(matches[2], campaignId)) {
                if (matches[1] == "seasonal") {
                    AddSeasonalCampaign(campaignId);
                } else if (matches[1] == "weekly") {
                    AddWeeklyCampaign(campaignId);
                } else if (Text::TryParseInt(matches[1], clubId)) {
                    AddClubCampaign(clubId, campaignId);
                } else {
                    _Logging::Error("Failed to add campaign from Trackmania.io link");
                }
            }
        } else if (Regex::Contains(str, "https:\\/\\/trackmania\\.com\\/clubs\\/\\d{1,6}\\/campaigns\\/.*?\\/\\d{1,6}\\/?$", regexFlags)) {
            // TODO, second ID doesn't match ID from API?
        } else if (Regex::IsMatch(str, "\\w{25,27}", regexFlags)) {
            AddFromUuid(str);
        } else {
            _Logging::Warn("Unknown URL received, map load might fail.");
            Maps.InsertLast(Map(str));
        }
    }

    void AddFolder(const string &in path) {
        try {
            if (!IO::FolderExists(path)) {
                _Logging::Warn("Failed to find folder in provided path. Make sure to use an absolute path!", true);
                return;
            }

            array<string> files = IO::IndexFolder(path, false);

            if (files.IsEmpty()) {
                _Logging::Warn("Failed to find any files in the provided folder!", true);
                return;
            }

            for (uint i = 0; i < files.Length; i++) {
                if (!files[i].ToLower().EndsWith(".map.gbx")) continue;
                AddFromFile(files[i].Replace("/", "\\"));
            }
        } catch {
            _Logging::Error("An error occurred while adding maps from folder in path \"" + path + "\": " + getExceptionInfo(), true);
        }
    }

    void AddSeasonalCampaign(int campaignId) {
        for (uint i = 0; i < SEASONAL_CAMPAIGNS.Length; i++) {
            Campaign@ season = SEASONAL_CAMPAIGNS[i];

            if (campaignId == season.Id) {
                startnew(CoroutineFuncUserdata(AddCampaign), season);
                return;
            }
        }

        _Logging::Error("Failed to find a seasonal campaign with that ID", true);
    }

    void AddWeeklyCampaign(int campaignId) {
        for (uint i = 0; i < WEEKLY_SHORTS.Length; i++) {
            Campaign@ week = WEEKLY_SHORTS[i];

            if (campaignId == week.Id) {
                startnew(CoroutineFuncUserdata(AddCampaign), week);
                return;
            }
        }

        _Logging::Error("Failed to find a weekly shorts week with that ID", true);
    }

    void AddClubCampaign(int clubId, int campaignId) {
        Campaign@ campaign = TM::GetClubCampaign(clubId, campaignId);

        if (campaign !is null) {
            startnew(CoroutineFuncUserdata(AddCampaign), campaign);
        }
    }
}
