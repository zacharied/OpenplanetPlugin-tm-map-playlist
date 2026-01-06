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

        savedPlaylists.InsertLast(save);
        UpdateFile();
    }

    void EditPlaylist(const string &in oldName, MapPlaylist save) {
        _Logging::Info("[EditPlaylist] Editing playlist \"" + oldName + "\".");

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            if (savedPlaylists[i].Name == oldName) {
                savedPlaylists[i].Maps = save.Maps;
                savedPlaylists[i].Name = save.Name;
                break;
            }
        }

        UpdateFile();
    }

    void DeletePlaylist(const string &in name) {
        _Logging::Info("[DeletePlaylist] Deleting playlist \"" + name + "\".");

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            if (savedPlaylists[i].Name == name) {
                savedPlaylists.RemoveAt(i);
                break;
            }
        }

        UpdateFile();
        SortSavedPlaylists();
    }

    void CreateFile() {
        _Logging::Trace("[CreateFile] Creating playlists file.");

        Json::Value@ json = Json::Array();

        Json::ToFile(SAVE_LOCATION, json);
    }

    void UpdateFile() {
        _Logging::Trace("[UpdateFile] Updating playlists file.");

        Json::Value@ json = Json::Array();

        foreach (MapPlaylist@ list : savedPlaylists) {
            json.Add(list.ToJson());
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
            savedPlaylists.InsertLast(list);
        }

        SortSavedPlaylists();
    }

    void SortSavedPlaylists() {
        if (savedPlaylists.Length > 1) {
            savedPlaylists.Sort(function(a, b) { 
                return a.CreatedAt < b.CreatedAt;
            });
        }
    }
}
