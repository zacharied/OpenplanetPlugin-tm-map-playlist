namespace Saves {
    const string SAVE_LOCATION = IO::FromStorageFolder("playlists.json");

    void SavePlaylist(MapPlaylist save) {
        _Logging::Info("[SavePlaylist] Saving playlist \"" + save.Name + "\" to file.");

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            MapPlaylist@ list = savedPlaylists[i];
            if (list.Name == save.Name) {
                _Logging::Warn("[SavePlaylist] Trying to add playlist \"" + save.Name + "\" when one with that name already exists!");
                return;
            }
        }

        save.CreatedAt = Time::Stamp;

        savedPlaylists.Add(save);
        UpdateFile();
    }

    void EditPlaylist(const string &in oldName, MapPlaylist save) {
        _Logging::Info("[EditPlaylist] Editing playlist \"" + oldName + "\".");

        savedPlaylists.Edit(oldName, save);
        UpdateFile();
    }

    void DeletePlaylist(const string &in name) {
        _Logging::Info("[DeletePlaylist] Deleting playlist \"" + name + "\".");

        savedPlaylists.Delete(name);
        UpdateFile();
    }

    void CreateFile() {
        _Logging::Trace("[CreateFile] Creating playlists file.");

        Json::Value@ json = Json::Array();

        Json::ToFile(SAVE_LOCATION, json);
    }

    void UpdateFile() {
        _Logging::Trace("[UpdateFile] Updating playlists file.");

        Json::Value@ json = Json::Array();

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            json.Add(savedPlaylists[i].ToJson());
        }

        _Logging::Debug(Json::Write(json, true));

        Json::ToFile(SAVE_LOCATION, json);
    }

    void LoadPlaylists() {
        if (!IO::FileExists(SAVE_LOCATION)) {
            CreateFile();
            return;
        }

        _Logging::Trace("[LoadPlaylists] Loading playlists file.");

        Json::Value@ json = Json::FromFile(SAVE_LOCATION);

        for (uint i = 0; i < json.Length; i++) {
            MapPlaylist@ list = MapPlaylist(json[i]);
            savedPlaylists.Add(list);
        }
    }
}
