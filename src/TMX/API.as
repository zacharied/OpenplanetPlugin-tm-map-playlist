namespace TMX {
    array<TmxTag@> Tags;

    MXMapInfo@ GetMap(int mapId) {
        string reqUrl = "https://trackmania.exchange/api/maps?count=1000&fields=" + MAP_FIELDS + "&id=" + mapId;

        _Logging::Trace("[GetMap] Fetching TMX map with ID #" + mapId);

        try {
            Json::Value json = API::GetAsync(reqUrl);

            _Logging::Debug("[GetMap] JSON:" + Json::Write(json));

            if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                _Logging::Error("[GetMap] Something went wrong while fetching map with ID #" + mapId, true);
                return null;
            }
            
            if (json["Results"].Length == 0) {
                _Logging::Error("[GetMap] Failed to find a map with ID #" + mapId + ". Map might be private or deleted.", true);
                return null;
            }

            return MXMapInfo(json["Results"][0]);
        } catch {
            _Logging::Error("[GetMap] An error occurred while fetching map with ID #" + mapId + " from TMX: " + getExceptionInfo(), true);
            return null;
        }
    }

    MXMappackInfo@ GetMappack(int mappackId) {
        string reqUrl = "https://trackmania.exchange/api/mappacks?fields=" + MAPPACK_FIELDS + "&id=" + mappackId;

        _Logging::Trace("[GetMappack] Fetching TMX mappack with ID #" + mappackId);

        try {
            Json::Value json = API::GetAsync(reqUrl);

            _Logging::Debug("[GetMappack] JSON:" + Json::Write(json));

            if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                _Logging::Error("[GetMappack] Something went wrong while fetching mappack with ID #" + mappackId);
                return null;
            }
            
            if (json["Results"].Length == 0) {
                _Logging::Error("[GetMappack] Failed to find a mappack with ID #" + mappackId + ". Mappack might not exist.", true);
                return null;
            }

            MXMappackInfo@ mappack = MXMappackInfo(json["Results"][0]);

            _Logging::Info("[GetMappack] Found mappack \"" + mappack.Name + "\" from ID #" + mappackId + ".");
            return mappack;
        } catch {
            _Logging::Error("[GetMappack] An error occurred while fetching mappack with ID #" + mappackId + ": " + getExceptionInfo(), true);
            return null;
        }
    }

    array<MXMapInfo@> GetMappackMaps(int mappackId) {
        array<MXMapInfo@> maps;
        bool moreMaps = true;
        int lastId = 0;

        _Logging::Trace("[GetMappackMaps] Getting maps from mappack ID " + mappackId);

        while (moreMaps) {
            string reqUrl = "https://trackmania.exchange/api/maps?count=1000&fields=" + MAP_FIELDS + "&mappackid=" + mappackId;
            if (moreMaps && lastId != 0) reqUrl += "&after=" + lastId;

            _Logging::Debug("[GetMappackMaps] Request URL: " + reqUrl);

            try {
                Json::Value json = API::GetAsync(reqUrl);

                _Logging::Debug("[GetMappackMaps] JSON: " + Json::Write(json));

                if (json.GetType() == Json::Type::Null || !json.HasKey("Results")) {
                    _Logging::Error("[GetMappackMaps] Something went wrong while fetching maps from mappack ID #" + mappackId, true);
                    return maps;
                } 

                if (json["Results"].Length == 0) {
                    if (maps.IsEmpty()) {
                        _Logging::Error("[GetMappackMaps] Found 0 maps for mappack ID #" + mappackId + ". Mappack might not exist or is empty", true);
                    }

                    return maps;
                }

                Json::Value@ items = json["Results"];
                moreMaps = json["More"];

                for (uint i = 0; i < items.Length; i++) {
                    MXMapInfo@ info = MXMapInfo(items[i]);
                    maps.InsertLast(info);

                    if (moreMaps && i == items.Length - 1) {
                        lastId = info.MapId;
                    }
                }

                if (moreMaps) {
                    sleep(1000);
                }
            } catch {
                _Logging::Error("[GetMappackMaps] An error occurred while fetching the maps from mappack ID #" + mappackId + ": " + getExceptionInfo(), true);
                return array<MXMapInfo@>();
            }
        }

        _Logging::Info("[GetMappackMaps] Found " + maps.Length + " maps from mappack ID #" + mappackId);
        return maps;
    }

    void GetTags() {
        string reqUrl = "https://trackmania.exchange/api/meta/tags";

        _Logging::Trace("[GetTags] Getting tags from TMX.");

        try {
            Json::Value json = API::GetAsync(reqUrl);

            if (json.GetType() == Json::Type::Null) {
                _Logging::Error("[GetTags] Something went wrong while fetching the tags from TMX", true);
                return;
            }
            
            for (uint i = 0; i < json.Length; i++) {
                TmxTag@ tag = TmxTag(json[i]);
                Tags.InsertLast(tag);
            }

            Tags.Sort(function(a, b) { return a.Name < b.Name; });
        } catch {
            _Logging::Error("[GetTags] An error occurred while fetching the tags from TMX: " + getExceptionInfo(), true);
            return;
        }
    }
}
