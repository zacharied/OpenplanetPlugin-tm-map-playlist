const bool HAS_PERMISSIONS = OpenplanetHasPaidPermissions();
const string TEMP_MAP_FOLDER = IO::FromUserGameFolder("Maps\\Temp\\");
const string USER_FOLDER = IO::FromUserGameFolder("");
const string PLUGIN_NAME = Meta::ExecutingPlugin().Name;
const string PLUGIN_ICON = Icons::List;
const string FULL_NAME = PLUGIN_ICON + " " + PLUGIN_NAME;
Json::Value savedPlaylists = Json::Object();

const array<string> MAP_FIELDS_ARRAY = {
    "MapId",
    "MapUid",
    "Uploader.Name",
    "MapType",
    "Name",
    "GbxMapName",
    "Medals.Author",
    "Medals.Gold",
    "Medals.Silver",
    "Medals.Bronze"
};

const string MAP_FIELDS = string::Join(MAP_FIELDS_ARRAY, ",");

enum GameMode {
    Race,
    Platform,
    Stunt
}

enum Medals {
	Bronze,
	Silver,
	Gold,
	Author
}