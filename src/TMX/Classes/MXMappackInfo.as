class MXMappackInfo {
    int ID;
    string Name;
    string Owner;
    int MapCount;
    array<Map@> Maps;

    MXMappackInfo(Json::Value@ json) {
        try {
            _Logging::Trace("Loading mappack info from TMX: " + Json::Write(json, true));

            this.ID = json["MappackId"];
            this.Name = json["Name"];
            this.MapCount = json["MapCount"];
            this.Owner = json["Owner"]["Name"];
        } catch {
            _Logging::Error("An error occurred while parsing the mappack info from TMX: " + getExceptionInfo(), true);
        }
    }

    void GetMaps() {
        if (this.MapCount > 1000) {
            _Logging::Warn("Mappack has more than 1000 maps. Please wait while maps are fetched.", true);
        }

        array<MXMapInfo@> mxMaps = TMX::GetMappackMaps(this.ID);

        foreach (MXMapInfo@ info : mxMaps) {
            this.Maps.InsertLast(Map(info));
        }
    }
}
