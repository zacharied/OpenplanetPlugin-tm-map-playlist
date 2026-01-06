class MXMapInfo {
    string Name = "Unknown";
    string GbxMapName;
    string MapUid;
    string OnlineMapId;
    string MapType;
    string Author = "Unknown";
    int MapId;
    int AuthorScore;
    int GoldScore;
    int SilverScore;
    int BronzeScore;
    array<TmxTag@> Tags;

    MXMapInfo(Json::Value@ json) {
        try {
            _Logging::Debug("Loading MX map info response: " + Json::Write(json, true));

            this.Name = json["Name"];
            this.MapUid = json["MapUid"];
            this.MapId = json["MapId"];

            if (json["OnlineMapId"].GetType() != Json::Type::Null) {
                this.OnlineMapId = json["OnlineMapId"];
            }

            if (json["GbxMapName"].GetType() != Json::Type::Null) {
                this.GbxMapName = json["GbxMapName"];
            } else {
                this.GbxMapName = this.Name;
            }

            if (json["MapType"].GetType() != Json::Type::Null) {
                this.MapType = json["MapType"];
            }

            if (json["Uploader"].GetType() != Json::Type::Null) {
                this.Author = json["Uploader"]["Name"];
            }

            if (json["Medals"].GetType() != Json::Type::Null) {
                this.AuthorScore = json["Medals"]["Author"];
                this.GoldScore = json["Medals"]["Gold"];
                this.SilverScore = json["Medals"]["Silver"];
                this.BronzeScore = json["Medals"]["Bronze"];
            }

            for (uint i = 0; i < json["Tags"].Length; i++) {
                Json::Value@ tag = json["Tags"][i];
                this.Tags.InsertLast(TmxTag(tag));
            }

            // Calling .Sort for maps without tags causes an out of bounds exception
            if (this.Tags.Length > 1) {
                this.Tags.Sort(function(a, b) { return a.Name < b.Name; });
            }
        } catch {
            _Logging::Error("An error occurred while parsing the map info from TMX: " + getExceptionInfo(), true);
        }
    }

    string get_DownloadURL() {
        return "http://trackmania.exchange/mapgbx/" + this.MapId;
    }

    string get_ThumbnailUrl() {
        return "http://trackmania.exchange/mapimage/" + this.MapId + "/1?hq=true";
    }
}
