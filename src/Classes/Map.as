class Map {
    string GbxName;
    string Name;
    string UID;
    string MapType;
    string Author = "Unknown";
    string URL;
    int AuthorTime = -1;
    int GoldTime = -1;
    int SilverTime = -1;
    int BronzeTime = -1;
    array<TmxTag@> Tags;

    // Used in campaigns
    int Position = -1;
    bool Selected = true;

    // NadeoServices
    Map(CNadeoServicesMap@ map) {
        _Logging::Trace("Loading map info from Nadeo Services response");

        try {
            URL = map.FileUrl;
            GbxName = Text::OpenplanetFormatCodes(map.Name);
            Name = Text::StripFormatCodes(map.Name);
            UID = map.Uid;
            MapType = CleanMapType(map.Type);
            AuthorTime = map.AuthorScore;
            GoldTime = map.GoldScore;
            SilverTime = map.SilverScore;
            BronzeTime = map.BronzeScore;

            string displayName = Cache::GetName(map.AuthorAccountId);

            if (displayName != "") {
                Author = displayName;
            } else if (map.AuthorDisplayName != "") {
                Author = map.AuthorDisplayName;
                Cache::SetName(map.AuthorAccountId, map.AuthorDisplayName);
            }
        } catch {
            _Logging::Error("An error occurred while parsing the map info from Nadeo Services: " + getExceptionInfo(), true);
        }
    }

    // GBX
    Map(CGameCtnChallenge@ map, const string &in path) {
        _Logging::Trace("Loading map info from GBX file");

        try {
            URL = path;
            GbxName = Text::OpenplanetFormatCodes(map.MapName);
            Name = Text::StripFormatCodes(map.MapName);
            UID = map.Id.GetName();
            MapType = CleanMapType(map.MapType);
            Author = map.AuthorNickName;
            AuthorTime = map.TMObjective_AuthorTime;
            GoldTime = map.TMObjective_GoldTime;
            SilverTime = map.TMObjective_SilverTime;
            BronzeTime = map.TMObjective_BronzeTime;
        } catch {
            _Logging::Error("An error occurred while parsing the map info from a GBX file: " + getExceptionInfo(), true);
        }
    }

    // MX
    Map(MXMapInfo@ mapInfo) {
        _Logging::Trace("Loading map info from MX response");

        try {
            URL = mapInfo.DownloadURL;
            Name = mapInfo.Name;
            GbxName = Text::OpenplanetFormatCodes(mapInfo.GbxMapName);
            UID = mapInfo.MapUid;
            MapType = CleanMapType(mapInfo.MapType);
            Author = mapInfo.Author;
            AuthorTime = mapInfo.AuthorTime;
            GoldTime = mapInfo.GoldTime;
            SilverTime = mapInfo.SilverTime;
            BronzeTime = mapInfo.BronzeTime;

            Tags = mapInfo.Tags;
        } catch {
            _Logging::Error("An error occurred while parsing the map info from ManiaExchange: " + getExceptionInfo(), true);
        }
    }

    // JSON
    Map(Json::Value@ json) {
        _Logging::Trace("Loading map info from JSON");
        _Logging::Trace(Json::Write(json, true));

        try {
            URL = json["URL"];
            Name = json["Name"];
            GbxName = json["GbxName"];
            UID = json["UID"];
            MapType = json["MapType"];
            Author = json["Author"];
            AuthorTime = json["AuthorTime"];
            GoldTime = json["GoldTime"];
            SilverTime = json["SilverTime"];
            BronzeTime = json["BronzeTime"];

            for (uint i = 0; i < json["Tags"].Length; i++) {
                Json::Value@ tag = json["Tags"][i];
                Tags.InsertLast(TmxTag(tag));
            }
        } catch {
            _Logging::Error("An error occurred while parsing the map info from JSON: " + getExceptionInfo(), true);
        }
    }

    // Unknown source
    Map(const string &in url) {
        URL = url;
    }

    bool opEquals(Map@ other) {
        if (this.UID != "" && other.UID != "") {
            return this.UID == other.UID;
        }

        return this.URL == other.URL;
    }

    GameMode get_GameMode() {
        if (this.MapType == "TM_Stunt") {
            return GameMode::Stunt;
        } else if (this.MapType == "TM_Platform") {
            return GameMode::Platform;
        }

        return GameMode::Race;
    }

    string toString() {
        if (this.Name == "") {
            return this.URL;
        }

        return this.Name + " (" + this.URL + ")";
    }

    Json::Value@ ToJson() {
        _Logging::Trace("Converting map info to JSON");

        Json::Value json = Json::Object();

        try {
            json["URL"] = URL;
            json["Name"] = Name;
            json["GbxName"] = GbxName;
            json["UID"] = UID;
            json["MapType"] = MapType;
            json["Author"] = Author;
            json["AuthorTime"] = AuthorTime;
            json["GoldTime"] = GoldTime;
            json["SilverTime"] = SilverTime;
            json["BronzeTime"] = BronzeTime;

            Json::Value tagsArray = Json::Array();

            for (uint i = 0; i < Tags.Length; i++) {
                TmxTag@ tag = Tags[i];
                tagsArray.Add(tag.ToJson());
            }

            json["Tags"] = tagsArray;

            return json;
        } catch {
            _Logging::Error("An error occurred while converting the map info to a JSON: " + getExceptionInfo(), true);
            return null;
        }
    }
}
