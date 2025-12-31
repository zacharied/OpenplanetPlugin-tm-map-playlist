class Map {
    string GbxName = "Unknown";
    string Name = "Unknown";
    string Uid;
    string MapType;
    string Author = "Unknown";
    string Url;
    string ThumbnailUrl;
    int AuthorScore = -1;
    int GoldScore = -1;
    int SilverScore = -1;
    int BronzeScore = -1;
    array<TmxTag@> Tags;
    int Index = -1;

    // Used in campaigns
    int Position = -1;

    Map() { }

    // NadeoServices
    Map(CNadeoServicesMap@ map) {
        _Logging::Trace("Loading map info from Nadeo Services response");

        try {
            this.Url = map.FileUrl;
            this.GbxName = Text::OpenplanetFormatCodes(map.Name);
            this.Name = Text::StripFormatCodes(map.Name);
            this.Uid = map.Uid;
            this.MapType = CleanMapType(map.Type);
            this.AuthorScore = map.AuthorScore;
            this.GoldScore = map.GoldScore;
            this.SilverScore = map.SilverScore;
            this.BronzeScore = map.BronzeScore;
            this.ThumbnailUrl = map.ThumbnailUrl;

            string displayName = Cache::GetName(map.AuthorAccountId);

            if (displayName != "") {
                this.Author = displayName;
            } else if (map.AuthorDisplayName != "") {
                this.Author = map.AuthorDisplayName;
                Cache::SetName(map.AuthorAccountId, map.AuthorDisplayName);
            }

            Cache::SetMapId(map.Uid, map.Id);
            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from Nadeo Services: " + getExceptionInfo(), true);
        }
    }

    // GBX
    Map(CGameCtnChallenge@ map, const string &in path) {
        _Logging::Trace("Loading map info from GBX file");

        try {
            this.Url = path;
            this.GbxName = Text::OpenplanetFormatCodes(map.MapName);
            this.Name = Text::StripFormatCodes(map.MapName);
            this.Uid = map.IdName;
            this.MapType = CleanMapType(map.MapType);
            this.Author = map.AuthorNickName;
            this.AuthorScore = map.TMObjective_AuthorTime;
            this.GoldScore = map.TMObjective_GoldTime;
            this.SilverScore = map.TMObjective_SilverTime;
            this.BronzeScore = map.TMObjective_BronzeTime;

            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from a GBX file: " + getExceptionInfo(), true);
        }
    }

    // MX
    Map(MXMapInfo@ mapInfo) {
        _Logging::Trace("Loading map info from MX response");

        try {
            this.Url = mapInfo.DownloadURL;
            this.Name = mapInfo.Name;
            this.GbxName = Text::OpenplanetFormatCodes(mapInfo.GbxMapName);
            this.Uid = mapInfo.MapUid;
            this.MapType = CleanMapType(mapInfo.MapType);
            this.Author = mapInfo.Author;
            this.AuthorScore = mapInfo.AuthorScore;
            this.GoldScore = mapInfo.GoldScore;
            this.SilverScore = mapInfo.SilverScore;
            this.BronzeScore = mapInfo.BronzeScore;
            this.Tags = mapInfo.Tags;
            this.ThumbnailUrl = mapInfo.ThumbnailUrl;

            Cache::SetMapId(mapInfo.MapUid, mapInfo.OnlineMapId);
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
            this.Url = json["Url"];
            this.Name = json["Name"];
            this.GbxName = json["GbxName"];
            this.Uid = json["Uid"];
            this.MapType = json["MapType"];
            this.Author = json["Author"];
            this.AuthorScore = json["AuthorScore"];
            this.GoldScore = json["GoldScore"];
            this.SilverScore = json["SilverScore"];
            this.BronzeScore = json["BronzeScore"];
            this.Index = json["Index"];
            this.ThumbnailUrl = json["ThumbnailUrl"];

            for (uint i = 0; i < json["Tags"].Length; i++) {
                Json::Value@ tag = json["Tags"][i];
                this.Tags.InsertLast(TmxTag(tag));
            }

            Cache::SetMap(this);
        } catch {
            _Logging::Error("An error occurred while parsing the map info from JSON: " + getExceptionInfo(), true);
        }
    }

    // Unknown source
    Map(const string &in url) {
        this.Url = url;
    }

    bool opEquals(Map@ other) {
        if (other is null) {
            return false;
        }

        if (this.Uid != "" && other.Uid != "") {
            return this.Uid == other.Uid;
        }
        
        if (this.Url != "" && other.Url != "") {
            return this.Url == other.Url;
        }

        return false;
    }

    bool HasTag(TmxTag@ tag) {
        return this.Tags.Find(tag) > -1;
    }

    void AddTag(TmxTag@ tag) {
        if (!this.HasTag(tag)) {
            this.Tags.InsertLast(tag);

            if (this.Tags.Length > 1) {
                this.Tags.Sort(function(a, b) { return a.Name < b.Name; });
            }
        }
    }

    void RemoveTag(TmxTag@ tag) {
        if (this.HasTag(tag)) {
            int tagIndex = this.Tags.Find(tag);
            this.Tags.RemoveAt(tagIndex);
        }
    }

    GameMode get_GameMode() {
        if (this.MapType == "TM_Stunt") {
            return GameMode::Stunt;
        }
        
        if (this.MapType == "TM_Platform") {
            return GameMode::Platform;
        }

        if (this.MapType == "TM_Royal") {
            return GameMode::Royal;
        }

        return GameMode::Race;
    }

    int GetMedalScore(Medals medal) {
        switch (medal) {
            case Medals::Bronze:
                return this.BronzeScore;
            case Medals::Silver:
                return this.SilverScore;
            case Medals::Gold:
                return this.GoldScore;
            case Medals::Author:
                return this.AuthorScore;
#if DEPENDENCY_WARRIORMEDALS
            case Medals::Warrior:
                if (this.HasWarrior) {
                    return this.WarriorScore;
                } else {
                    return this.AuthorScore;
                }
#endif
            default:
                return this.AuthorScore;
        }
    }

    bool get_HasPb() {
        if (this.GameMode == GameMode::Platform) {
            return this.Pb > -1;
        }

        return this.Pb > 0;
    }

    int get_Pb() {
        if (PB_UIDS.Exists(this.Uid)) {
            return int(PB_UIDS[this.Uid]);
        }

        return -1;
    }

    bool get_IsPbSecret() {
        if (!HasPb) {
            return false;
        }

        return uint(Pb) == uint(-1);
    }

    bool get_HasWarrior() {
        if (this.GameMode != GameMode::Race) {
            return false;
        }

        return this.WarriorScore > 0;
    }

    int get_WarriorScore() {
        if (this.GameMode != GameMode::Race || this.Uid == "") {
            return 0;
        }

#if DEPENDENCY_WARRIORMEDALS
        return WarriorMedals::GetWMTime(this.Uid);
#else
        return 0;
#endif
    }

    string toString() {
        if (this.Name == "") {
            return this.Url;
        }

        return this.Name + " (" + this.Uid + ")";
    }

    Json::Value@ ToJson() {
        _Logging::Trace("Converting map info to JSON");

        Json::Value json = Json::Object();

        try {
            json["Url"] = this.Url;
            json["Name"] = this.Name;
            json["GbxName"] = this.GbxName;
            json["Uid"] = this.Uid;
            json["MapType"] = this.MapType;
            json["Author"] = this.Author;
            json["AuthorScore"] = this.AuthorScore;
            json["GoldScore"] = this.GoldScore;
            json["SilverScore"] = this.SilverScore;
            json["BronzeScore"] = this.BronzeScore;
            json["Pb"] = this.Pb; // not used but in case it's needed in the future
            json["Index"] = this.Index;
            json["ThumbnailUrl"] = this.ThumbnailUrl;

            Json::Value tagsArray = Json::Array();

            for (uint i = 0; i < this.Tags.Length; i++) {
                TmxTag@ tag = this.Tags[i];
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
