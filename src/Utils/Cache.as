namespace Cache {
    dictionary AuthorNames = {
        { "d2372a08-a8a1-46cb-97fb-23a161d85ad0", "Nadeo" } // Maps uploaded by the old Nadeo account return an empty string for the Author
    };

    dictionary Maps;
    dictionary MapIds;
    dictionary MapUids;
    Json::Value@ idsJson = Json::FromFile(IDS_LOCATION);

    string GetName(const string &in authorId) {
        string name;

        if (AuthorNames.Get(authorId, name)) {
            return name;
        }

#if DEPENDENCY_NADEOSERVICES
        name = NadeoServices::GetDisplayNameAsync(authorId);
        AuthorNames.Set(authorId, name);
#endif

        return name;
    }

    void SetName(const string &in name, const string &in authorId) {
        if (!AuthorNames.Exists(authorId) || string(AuthorNames[authorId]) == "") {
            AuthorNames.Set(authorId, name);
        }
    }

    void LoadIdCache() {
        if (idsJson.GetType() == Json::Type::Null) {
            return;
        }

        _Logging::Debug("Loading map UIDs and IDs caches from JSON.");

        MapIds = JsonToDict(idsJson);

        array<string> keys = MapIds.GetKeys();

        for (uint i = 0; i < keys.Length; i++) {
            string key = keys[i];
            MapUids.Set(string(MapIds[key]), key);
        }
    }

    void StoreMapIds() {
        if (MapIds.IsEmpty()) {
            return;
        }

        _Logging::Debug("Storing map UIDs and IDs caches in JSON.");
        Json::ToFile(IDS_LOCATION, MapIds.ToJson(), true);
    }

    string GetMapId(const string &in mapUid) {
        string mapId;
        MapIds.Get(mapUid, mapId);

        return mapId;
    }

    string GetMapUid(const string &in mapId) {
        string mapUid;
        MapUids.Get(mapId, mapUid);

        return mapUid;
    }

    void SetMapId(const string &in mapUid, const string &in mapId) {
        if (mapUid == "" || mapId == "") {
            return;
        }
        
        if (!MapIds.Exists(mapUid)) {
            MapIds.Set(mapUid, mapId);
            MapUids.Set(mapId, mapUid);
        }
    }

    Map@ GetMap(const string &in mapUid) {
        if (!Maps.Exists(mapUid)) {
            return null;
        }

        Map@ map = cast<Map>(Maps[mapUid]);

        return map;
    }

    void SetMap(Map map) {
        if (!Maps.Exists(map.Uid)) {
            Maps.Set(map.Uid, map);
        }
    }

    void ClearMapCache() {
        _Logging::Debug("Clearing map cache with " + Maps.GetSize() + " maps.");

        Maps.DeleteAll();
    }
}
