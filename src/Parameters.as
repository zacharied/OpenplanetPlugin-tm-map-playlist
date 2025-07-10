const bool HAS_PERMISSIONS      = OpenplanetHasPaidPermissions();
const string TEMP_MAP_FOLDER    = IO::FromUserGameFolder("Maps\\Temp\\");
const string USER_FOLDER        = IO::FromUserGameFolder("");
const string PLUGIN_NAME        = Meta::ExecutingPlugin().Name;
const string PLUGIN_ICON        = Icons::List;
const string FULL_NAME          = PLUGIN_ICON + " " + PLUGIN_NAME;
const float UI_SCALE            = UI::GetScale();

Json::Value savedPlaylists      = Json::Object();
MapPlaylist@ playlist           = MapPlaylist();
MapColumns@ columnWidths        = MapColumns();

array<Campaign@> WEEKLY_SHORTS;
array<Campaign@> SEASONAL_CAMPAIGNS;
array<Map@> FAVORITES;

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
    "Medals.Bronze",
    "Tags"
};

const string MAP_FIELDS = string::Join(MAP_FIELDS_ARRAY, ",");

const array<string> MAPPACK_FIELDS_ARRAY = {
    "MappackId",
    "Name",
    "MapCount",
    "Owner.Name",
    "Owner.UserId",
    "CreatedAt"
};

const string MAPPACK_FIELDS = string::Join(MAPPACK_FIELDS_ARRAY, ",");

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

// TODO support club campaigns (tm.com)
enum Source {
    TMX_Map_ID,
    TMX_Mappack_ID,
    URL,
    Weekly_Shorts,
    Seasonal_Campaign,
    Club_Campaign,
    UID,
    Favorites,
    File,
    Folder,
    Last
}
