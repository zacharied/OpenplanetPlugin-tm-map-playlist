class MXMapInfo {
    string Name;
    string GbxMapName;
    string MapUid;
    string MapType;
    string Author = "Unknown";
    int MapId;
    int AuthorScore;
    int GoldScore;
    int SilverScore;
    int BronzeScore;
    array<TmxTag@> Tags;

    MXMapInfo(Json::Value@ json) {
        _Logging::Debug("Loading MX map info response: " + Json::Write(json, true));

        Name = json["Name"];
        MapUid = json["MapUid"];
        MapId = json["MapId"];

        if (json["GbxMapName"].GetType() != Json::Type::Null) {
            GbxMapName = json["GbxMapName"];
        } else {
            GbxMapName = Name;
        }

        if (json["MapType"].GetType() != Json::Type::Null) {
            MapType = json["MapType"];
        }

        if (json["Uploader"].GetType() != Json::Type::Null) {
            Author = json["Uploader"]["Name"];
        }

        if (json["Medals"].GetType() != Json::Type::Null) {
            AuthorScore = json["Medals"]["Author"];
            GoldScore = json["Medals"]["Gold"];
            SilverScore = json["Medals"]["Silver"];
            BronzeScore = json["Medals"]["Bronze"];
        }

        for (uint i = 0; i < json["Tags"].Length; i++) {
            Json::Value@ tag = json["Tags"][i];
            Tags.InsertLast(TmxTag(tag));
        }
    }

    string get_DownloadURL() {
        return "http://trackmania.exchange/mapgbx/" + MapId;
    }
}
