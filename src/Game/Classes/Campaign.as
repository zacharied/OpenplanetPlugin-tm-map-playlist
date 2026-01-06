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
        try {
            _Logging::Debug("Loading campaign information: " + Json::Write(json, true));

            this.Id = json["id"];
            this.Name = json["name"];
            this.SeasonUid = json["seasonUid"];
            this.ClubId = json["clubId"];
            this.StartTimestamp = json["startTimestamp"];
            this.EndTimestamp = json["endTimestamp"];
            this.Year = json["year"];
            this.Week = json["week"];
            this.Day = json["day"];

            for (uint i = 0; i < json["playlist"].Length; i++) {
                Json::Value@ map = json["playlist"][i];
                this.MapUids.InsertLast(string(map["mapUid"]));
            }
        } catch {
            _Logging::Error("An error occurred while parsing the campaign info from Nadeo Services: " + getExceptionInfo(), true);
        }
    }

    uint get_Length() {
        if (!this.LoadedData) {
            return this.MapUids.Length;
        }

        return this.MapList.Length;
    }

    void LoadMapData() {
        if (this.LoadedData) {
            // Data was already loaded
            return;
        }

        _Logging::Debug("Loading data for " + this.MapUids.Length + " maps in the \"" + this.Name + "\" campaign.");
        startnew(CoroutineFunc(this.GetMaps));
    }

    void GetMaps() {
        auto maps = TM::GetMultipleMapsFromUids(this.MapUids);

        // Position is needed because anonymous functions can't access MapUids directly
        for (uint i = 0; i < maps.Length; i++) {
            Map@ map = Map(maps[i]);
            map.Position = this.MapUids.Find(map.Uid);
            this.MapList.InsertLast(map);
        }

        // Map_NadeoServices_GetListFromUid doesn't return maps in order
        if (this.MapList.Length > 1) {
            this.MapList.Sort(function(a, b) { 
                return a.Position < b.Position;
            });
        }

        this._Loaded = true;
    }

    bool get_LoadedData() {
        return this._Loaded;
    }

    bool IsNewer(Campaign@ other) {
        if (this.StartTimestamp > 0 && other.StartTimestamp > 0) {
            return this.StartTimestamp > other.StartTimestamp;
        }

        return this.Id > other.Id;
    }

    bool opEquals(Campaign@ other) {
        return other !is null && this.Id == other.Id;
    }
}
