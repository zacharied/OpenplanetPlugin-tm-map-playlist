namespace Cache {
    dictionary g_authorNames = {
        { "d2372a08-a8a1-46cb-97fb-23a161d85ad0", "Nadeo" } // Maps uploaded by the old Nadeo account return an empty string for the Author
    };

    dictionary g_maps;
    dictionary g_mapIds;
    dictionary g_mapUids;
    dictionary g_pbs;
    dictionary g_sessionPbs;
    dictionary g_thumbnailUrls;
    const Json::Value@ g_idsJson = Json::FromFile(IDS_LOCATION);

    string GetName(const string &in authorId) {
        string name;

        if (g_authorNames.Get(authorId, name)) {
            return name;
        }

#if DEPENDENCY_NADEOSERVICES
        name = NadeoServices::GetDisplayNameAsync(authorId);
        g_authorNames.Set(authorId, name);
#endif

        return name;
    }

    void SetName(const string &in name, const string &in authorId) {
        if (!g_authorNames.Exists(authorId) || string(g_authorNames[authorId]) == "") {
            g_authorNames.Set(authorId, name);
        }
    }

    string GetThumbnailUrl(const string &in mapUid) {
        string thumbUrl = "";
        g_thumbnailUrls.Get(mapUid, thumbUrl);

        return thumbUrl;
    }

    void SetThumbnailUrl(const string &in mapUid, const string &in url) {
        if (mapUid == "" || url == "") {
            return;
        }

        // Prioritize TMX thumbnails
        if (!g_thumbnailUrls.Exists(mapUid) || url.Contains("exchange")) {
            g_thumbnailUrls.Set(mapUid, url);
        }
    }

    int GetPb(const string &in mapUid) {
        int64 pb = -1;
        g_pbs.Get(mapUid, pb);

        return pb;
    }

    void SetPb(const string &in mapUid, int pb, bool stunt = false) {
        if (mapUid == "" || pb == -1) {
            return;
        }

        int oldPb = GetPb(mapUid);

        if (oldPb > -1) {
            if (stunt && pb <= oldPb) { 
                return; 
            }

            if (!stunt && pb >= oldPb) {
                return;
            }
        }

        g_pbs.Set(mapUid, pb);
    }

    int GetSessionPb(const string &in mapUid) {
        int64 pb = -1;
        g_sessionPbs.Get(mapUid, pb);

        return pb;
    }

    void SetSessionPb(const string &in mapUid, int pb, bool stunt = false) {
        if (mapUid == "" || pb == -1) {
            return;
        }

        int oldPb = GetSessionPb(mapUid);

        if (oldPb > -1) {
            if (stunt && pb <= oldPb) { 
                return; 
            }

            if (!stunt && pb >= oldPb) {
                return;
            }
        }

        g_sessionPbs.Set(mapUid, pb);
    }

    void LoadIdCache() {
        if (g_idsJson.GetType() == Json::Type::Null) {
            return;
        }

        _Logging::Trace("[LoadIdCache] Loading map UIDs and IDs caches from JSON.");

        g_mapIds = JsonToDict(g_idsJson);

        array<string> keys = g_mapIds.GetKeys();

        foreach (string key : keys) {
            g_mapUids.Set(string(g_mapIds[key]), key);
        }
    }

    void StoreMapIds() {
        if (g_mapIds.IsEmpty()) {
            return;
        }

        _Logging::Trace("[StoreMapIds] Storing map UIDs and IDs caches in JSON.");
        Json::ToFile(IDS_LOCATION, g_mapIds.ToJson(), true);
    }

    string GetMapId(const string &in mapUid) {
        string mapId;
        g_mapIds.Get(mapUid, mapId);

        return mapId;
    }

    string GetMapUid(const string &in mapId) {
        string mapUid;
        g_mapUids.Get(mapId, mapUid);

        return mapUid;
    }

    void SetMapId(const string &in mapUid, const string &in mapId) {
        if (mapUid == "" || mapId == "") {
            return;
        }
        
        if (!g_mapIds.Exists(mapUid)) {
            g_mapIds.Set(mapUid, mapId);
            g_mapUids.Set(mapId, mapUid);
        }
    }

    Map@ GetMap(const string &in mapUid) {
        if (!g_maps.Exists(mapUid)) {
            return null;
        }

        Map@ map = cast<Map>(g_maps[mapUid]);

        return map;
    }

    void SetMap(Map map) {
        if (!g_maps.Exists(map.Uid)) {
            g_maps.Set(map.Uid, map);
        }
    }

    void ClearMapCache() {
        _Logging::Trace("[ClearMapCache] Clearing map cache with " + g_maps.GetSize() + " maps.");

        g_maps.DeleteAll();
    }

    void ClearSessionPBs() {
        _Logging::Trace("[ClearSessionPBs] Clearing session PBs cache with " + g_sessionPbs.GetSize() + " PBs.");

        g_sessionPbs.DeleteAll();
    }
}
