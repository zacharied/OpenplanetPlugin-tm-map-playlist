namespace TMX {
	MXMapInfo@ GetMap(int mapId) {
        string reqUrl = "https://trackmania.exchange/api/maps?count=100&fields=" + MAP_FIELDS + "&id=" + mapId;

        try {
            Json::Value json = API::GetAsync(reqUrl);

            if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                _Logging::Error("Something went wrong while fetching map with ID #" + mapId, true);
                _Logging::Debug(Json::Write(json));

                return null;
            } else if (json["Results"].Length == 0) {
                _Logging::Error("Failed to find a map with ID #" + mapId + ". Map might be private or deleted.", true);
                return null;
            }

            return MXMapInfo(json["Results"][0]);
		} catch {
            _Logging::Error("An error occurred while fetching map with ID #" + mapId + "from TMX: " + getExceptionInfo(), true);
            return null;
        }
	}

    array<MXMapInfo@> GetMappack(int mappackId) {
        string reqUrl = "https://trackmania.exchange/api/maps?count=100&fields=" + MAP_FIELDS + "&mappackid=" + mappackId;
        array<MXMapInfo@> maps;

        try {
            Json::Value json = API::GetAsync(reqUrl);

            if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                _Logging::Error("Something went wrong while fetching maps from mappack ID #" + mappackId, true);
                _Logging::Debug(Json::Write(json));

                return maps;
            } else if (json["Results"].Length == 0) {
                _Logging::Error("Found 0 maps for mappack ID #" + mappackId + ". Mappack might not exist or is empty", true);
                return maps;
            }

            Json::Value@ items = json["Results"];

            for (uint i = 0; i < items.Length; i++) {
                maps.InsertLast(MXMapInfo(items[i]));
            }

            _Logging::Info("Found " + items.Length + " maps from mappack ID #" + mappackId);

            if (bool(json["More"])) {
                _Logging::Warn("Mappack has more than 100 maps! Fetched the first 100", true);
            }

            return maps;
        } catch {
            _Logging::Error("An error occurred while fetching the maps from mappack ID #" + mappackId + ": " + getExceptionInfo(), true);
            return array<MXMapInfo@>();
        }
    }
}
