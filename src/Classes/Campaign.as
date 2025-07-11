array<string>@ campaignUids;

class Campaign {
    int Id;
    string Name;
    string SeasonUid;
    int ClubId;
    int StartTimestamp;
    int EndTimestamp;
    int Year;
    int Week;
    int Day;
    array<string> MapUids;
    array<Map@> MapList;
    bool _Loaded = false;

    Campaign() { }

    Campaign(Json::Value@ json) {
        _Logging::Debug("Loading campaign information: " + Json::Write(json, true));

        Id = json["id"];
        Name = json["name"];
        SeasonUid = json["seasonUid"];
        ClubId = json["clubId"];
        StartTimestamp = json["startTimestamp"];
        EndTimestamp = json["endTimestamp"];
        Year = json["year"];
        Week = json["week"];
        Day = json["day"];

        for (uint i = 0; i < json["playlist"].Length; i++) {
            Json::Value@ map = json["playlist"][i];
            MapUids.InsertLast(string(map["mapUid"]));
        }
    }

    uint get_Length() {
        if (!_Loaded) {
            return MapUids.Length;
        }

        return MapList.Length;
    }

    void LoadMapData() {
        if (LoadedData) {
            // Data was already loaded
            return;
        }

        _Logging::Debug("Loading data for " + MapUids.Length + " maps in the \"" + Name + "\" campaign.");
        startnew(CoroutineFunc(GetMaps));
    }

    void GetMaps() {
        auto maps = TM::GetMultipleMapsFromUids(MapUids);

        for (uint i = 0; i < maps.Length; i++) {
            Map@ map = Map(maps[i]);
            map.Position = MapUids.Find(map.UID);
            MapList.InsertLast(map);
        }

        // Map_NadeoServices_GetListFromUid doesn't return maps in order
        if (MapList.Length > 1) {
            MapList.Sort(function(a, b) { 
                return a.Position < b.Position;
            });
        }

        _Loaded = true;
    }

    bool get_LoadedData() {
        return _Loaded;
    }

    bool IsNewer(Campaign@ other) {
        if (this.StartTimestamp > 0 && other.StartTimestamp > 0) {
            return this.StartTimestamp > other.StartTimestamp;
        }

        return this.Id > other.Id;
    }

    bool OpEquals(Campaign@ other) {
        return Id == other.Id;
    }
}
