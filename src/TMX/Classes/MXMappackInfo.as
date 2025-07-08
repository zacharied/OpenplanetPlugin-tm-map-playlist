class MXMappackInfo {
    int ID;
    string Name;
    string Owner;
    int MapCount;
    array<Map@> Maps;

    MXMappackInfo(Json::Value@ json) {
        ID = json["MappackId"];
        Name = json["Name"];
        MapCount = json["MapCount"];
        Owner = json["Owner"]["Name"];
    }

    void GetMaps() {
        if (MapCount > 200) {
            _Logging::Warn("Mappack has more than 200 maps. Please wait while maps are fetched.", true);
        }

        array<MXMapInfo@> mxMaps = TMX::GetMappackMaps(ID);

        for (uint i = 0; i < mxMaps.Length; i++) {
            MXMapInfo@ info = mxMaps[i];
            Maps.InsertLast(Map(info));
        }
    }
}
