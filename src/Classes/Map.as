class Map {
    string GbxName;
    string Name;
    string Uid;
    string MapType;
    string Author = "Unknown";
    string Url;
    int AuthorScore = -1;
    int GoldScore = -1;
    int SilverScore = -1;
    int BronzeScore = -1;
    array<TmxTag@> Tags;

    // Used in campaigns
    int Position = -1;
    bool Selected = true;

    Map() { }

    // NadeoServices
    Map(CNadeoServicesMap@ map) {
        _Logging::Trace("Loading map info from Nadeo Services response");

        try {
            Url = map.FileUrl;
            GbxName = Text::OpenplanetFormatCodes(map.Name);
            Name = Text::StripFormatCodes(map.Name);
            Uid = map.Uid;
            MapType = CleanMapType(map.Type);
            AuthorScore = map.AuthorScore;
            GoldScore = map.GoldScore;
            SilverScore = map.SilverScore;
            BronzeScore = map.BronzeScore;

            string displayName = Cache::GetName(map.AuthorAccountId);

            if (displayName != "") {
                Author = displayName;
            } else if (map.AuthorDisplayName != "") {
                Author = map.AuthorDisplayName;
                Cache::SetName(map.AuthorAccountId, map.AuthorDisplayName);
            }

            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from Nadeo Services: " + getExceptionInfo(), true);
        }
    }

    // GBX
    Map(CGameCtnChallenge@ map, const string &in path) {
        _Logging::Trace("Loading map info from GBX file");

        try {
            Url = path;
            GbxName = Text::OpenplanetFormatCodes(map.MapName);
            Name = Text::StripFormatCodes(map.MapName);
            Uid = map.Id.GetName();
            MapType = CleanMapType(map.MapType);
            Author = map.AuthorNickName;
            AuthorScore = map.TMObjective_AuthorTime;
            GoldScore = map.TMObjective_GoldTime;
            SilverScore = map.TMObjective_SilverTime;
            BronzeScore = map.TMObjective_BronzeTime;

            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from a GBX file: " + getExceptionInfo(), true);
        }
    }

    // MX
    Map(MXMapInfo@ mapInfo) {
        _Logging::Trace("Loading map info from MX response");

        try {
            Url = mapInfo.DownloadURL;
            Name = mapInfo.Name;
            GbxName = Text::OpenplanetFormatCodes(mapInfo.GbxMapName);
            Uid = mapInfo.MapUid;
            MapType = CleanMapType(mapInfo.MapType);
            Author = mapInfo.Author;
            AuthorScore = mapInfo.AuthorScore;
            GoldScore = mapInfo.GoldScore;
            SilverScore = mapInfo.SilverScore;
            BronzeScore = mapInfo.BronzeScore;
            Tags = mapInfo.Tags;

            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from ManiaExchange: " + getExceptionInfo(), true);
        }
    }

    // JSON
    Map(Json::Value@ json) {
        _Logging::Trace("Loading map info from JSON");
        _Logging::Trace(Json::Write(json, true));

        try {
            Url = json["Url"];
            Name = json["Name"];
            GbxName = json["GbxName"];
            Uid = json["Uid"];
            MapType = json["MapType"];
            Author = json["Author"];
            AuthorScore = json["AuthorScore"];
            GoldScore = json["GoldScore"];
            SilverScore = json["SilverScore"];
            BronzeScore = json["BronzeScore"];

            for (uint i = 0; i < json["Tags"].Length; i++) {
                Json::Value@ tag = json["Tags"][i];
                Tags.InsertLast(TmxTag(tag));
            }

            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from JSON: " + getExceptionInfo(), true);
        }
    }

    // Unknown source
    Map(const string &in url) {
        Url = url;
    }

    bool opEquals(Map@ other) {
        if (this.Uid != "" && other.Uid != "") {
            return this.Uid == other.Uid;
        }

        return this.Url == other.Url;
    }

    GameMode get_GameMode() {
        if (this.MapType == "TM_Stunt") {
            return GameMode::Stunt;
        } else if (this.MapType == "TM_Platform") {
            return GameMode::Platform;
        } else if (this.MapType == "TM_Royal") {
            return GameMode::Royal;
        }

        return GameMode::Race;
    }

    int GetMedal(Medals medal) {
        switch (medal) {
            case Medals::Bronze:
                return BronzeScore;
            case Medals::Silver:
                return SilverScore;
            case Medals::Gold:
                return GoldScore;
            case Medals::Author:
            default:
                return AuthorScore;
        }
    }

    string toString() {
        if (this.Name == "") {
            return this.Url;
        }

        return this.Name + " (" + this.Url + ")";
    }

    Json::Value@ ToJson() {
        _Logging::Trace("Converting map info to JSON");

        Json::Value json = Json::Object();

        try {
            json["Url"] = Url;
            json["Name"] = Name;
            json["GbxName"] = GbxName;
            json["Uid"] = Uid;
            json["MapType"] = MapType;
            json["Author"] = Author;
            json["AuthorScore"] = AuthorScore;
            json["GoldScore"] = GoldScore;
            json["SilverScore"] = SilverScore;
            json["BronzeScore"] = BronzeScore;

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
