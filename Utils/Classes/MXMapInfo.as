class MXMapInfo {
    string Name;
    string GbxMapName;
    string MapUid;
    string MapType;
    string Author = "Unknown";
    int MapId;
    int AuthorTime;
    int GoldTime;
    int SilverTime;
    int BronzeTime;

    MXMapInfo(Json::Value@ json) {
        _Logging::Debug("Loading MX map info response" + Json::Write(json, true));

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
            AuthorTime = json["Medals"]["Author"];
            GoldTime = json["Medals"]["Gold"];
            SilverTime = json["Medals"]["Silver"];
            BronzeTime = json["Medals"]["Bronze"];
        }
    }

    string get_DownloadURL() {
        return "http://trackmania.exchange/mapgbx/" + MapId;
    }
}
