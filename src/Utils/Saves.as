namespace Saves {
    const string SAVE_LOCATION = IO::FromStorageFolder("playlists.json");

    void SavePlaylist(MapPlaylist save) {
        _Logging::Info("Saving playlist \"" + save.Name + "\" to file.");

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            MapPlaylist@ list = savedPlaylists[i];
            if (list.Name == save.Name) {
                _Logging::Warn("Trying to add playlist \"" + save.Name + "\" when one with that name already exists!");
                return;
            }
        }

        save.CreatedAt = Time::Stamp;

        savedPlaylists.InsertLast(save);
        UpdateFile();
    }

    void EditPlaylist(const string &in oldName, MapPlaylist save) {
        _Logging::Info("Editing playlist \"" + oldName + "\".");

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            MapPlaylist@ list = savedPlaylists[i];
            if (list.Name == oldName) {
                savedPlaylists[i].Maps = save.Maps;
                savedPlaylists[i].Name = save.Name;
                break;
            }
        }

        UpdateFile();
    }

    void DeletePlaylist(const string &in name) {
        _Logging::Info("Deleting playlist \"" + name + "\".");

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            MapPlaylist@ list = savedPlaylists[i];
            if (list.Name == name) {
                savedPlaylists.RemoveAt(i);
                break;
            }
        }

        UpdateFile();
        SortPlaylists();
    }

    void CreateFile() {
        _Logging::Trace("Creating playlists file.");

        Json::Value@ json = Json::Array();

        Json::ToFile(SAVE_LOCATION, json);
    }

    void UpdateFile() {
        _Logging::Trace("Updating playlists file.");

        Json::Value@ json = Json::Array();

        for (uint i = 0; i < savedPlaylists.Length; i++) {
            MapPlaylist@ list = savedPlaylists[i];
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

        _Logging::Trace("Loading playlists file.");

        Json::Value@ json = Json::FromFile(SAVE_LOCATION);

        for (uint i = 0; i < json.Length; i++) {
            MapPlaylist@ list = MapPlaylist(json[i]);
            savedPlaylists.InsertLast(list);
        }

        SortPlaylists();
    }

    void SortPlaylists() {
        if (savedPlaylists.Length > 1) {
            savedPlaylists.Sort(function(a, b) { 
                return a.CreatedAt < b.CreatedAt;
            });
        }
    }
}
