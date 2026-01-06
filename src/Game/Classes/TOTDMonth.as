array<string> monthStrings = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

class TOTDMonth : Campaign {
    int LastDay;
    int Month;

    TOTDMonth(Json::Value@ json) {
        try {
            _Logging::Debug("Loading TOTD month information: " + Json::Write(json, true));

            this.Year = json["year"];
            this.Month = json["month"];
            this.LastDay = json["lastDay"];
            this.Name = monthStrings[this.Month - 1] + " " + this.Year;

            for (uint i = 0; i < json["days"].Length; i++) {
                Json::Value@ map = json["days"][i];
                this.MapUids.InsertLast(string(map["mapUid"]));
            }
        } catch {
            _Logging::Error("An error occurred while parsing the TOTD month info from Nadeo Services: " + getExceptionInfo(), true);
        }
    }

    void LoadMapData() override {
        if (this.LoadedData) {
            // Data was already loaded
            return;
        }

        _Logging::Debug("Loading data for " + this.MapUids.Length + " maps in the \"" + this.Name + "\" TOTD month.");
        startnew(CoroutineFunc(this.GetMaps));
    }

    bool IsNewer(TOTDMonth@ other) {
        if (this.Year != other.Year) {
            return this.Year > other.Year;
        }

        return this.Month > other.Month;
    }

    bool opEquals(TOTDMonth@ other) {
        return other !is null && this.Year == other.Year && this.Month == other.Month;
    }
}
