namespace Saves {
    const string SAVE_LOCATION = IO::FromStorageFolder("playlists.json");

    void SavePlaylist(const string &in name, Json::Value@ save, bool edit = false) {
        if (save.GetType() != Json::Type::Object) {
            _Logging::Error("Invalid JSON type for playlist. Expected object, received " + tostring(save.GetType()));
            return;
        }

        _Logging::Info("Saving playlist \"" + name + "\" to file.");
        _Logging::Debug(Json::Write(save, true));

        if (savedPlaylists.GetType() == Json::Type::Null) {
            _Logging::Debug("Failed to find playlist file when saving playlist. Creating...");
            CreateFile();
        } else if (!edit && savedPlaylists.HasKey(name)) {
            _Logging::Warn("Trying to add playlist \"" + name + "\" when one with that name already exists!");
            return;
        }

        save["Name"] = name;

        savedPlaylists[name] = save;
        UpdateFile();
    }

    void DeletePlaylist(const string &in name) {
        _Logging::Info("Deleting playlist \"" + name + "\".");

        if (savedPlaylists.GetType() == Json::Type::Null) {
            _Logging::Warn("Trying to delete playlist when playlists file doesn't exist. Please report this to the devs.", true);
            return;
        } else if (!savedPlaylists.HasKey(name)) {
            _Logging::Error("Playlists file doesn't have a playlist called \"" + name + "\"", true);
            return;
        }

        savedPlaylists.Remove(name);
        UpdateFile();
    }

    void CreateFile() {
        _Logging::Trace("Creating playlists file.");

        savedPlaylists = Json::Object();

        Json::ToFile(SAVE_LOCATION, savedPlaylists);
    }

    void UpdateFile() {
        _Logging::Trace("Updating playlists file.");
        _Logging::Debug(Json::Write(savedPlaylists, true));

        Json::ToFile(SAVE_LOCATION, savedPlaylists);
    }

    void LoadPlaylists() {
        if (!IO::FileExists(SAVE_LOCATION)) {
            CreateFile();
            return;
        }

        _Logging::Trace("Loading playlists file.");

        savedPlaylists = Json::FromFile(SAVE_LOCATION);
    }
}
