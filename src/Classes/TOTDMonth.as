array<string> monthStrings = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

class TOTDMonth : Campaign {
    int LastDay;
    int Month;

    TOTDMonth(Json::Value@ json) {
        _Logging::Debug("Loading TOTD month information: " + Json::Write(json, true));

        Year = json["year"];
        Month = json["month"];
        LastDay = json["lastDay"];
        Name = monthStrings[Month - 1] + " " + Year;

        for (uint i = 0; i < json["days"].Length; i++) {
            Json::Value@ map = json["days"][i];
            MapUids.InsertLast(string(map["mapUid"]));
        }
    }

    void LoadMapData() override {
        if (LoadedData) {
            // Data was already loaded
            return;
        }

        _Logging::Debug("Loading data for " + MapUids.Length + " maps in the \"" + Name + "\" TOTD month.");
        startnew(CoroutineFunc(GetMaps));
    }

    bool IsNewer(TOTDMonth@ other) {
        if (this.Year != other.Year) {
            return this.Year > other.Year;
        }

        return this.Month > other.Month;
    }

    bool OpEquals(TOTDMonth@ other) {
        return this.Year == other.Year && this.Month == other.Month;
    }
}
