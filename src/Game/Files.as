namespace TM {
    CGameCtnChallenge@ GetMapFromFid(const string &in fileName, const string &in folder = "Maps\\Temp") {
        _Logging::Trace("[GetMapFromFid] Getting map \"" + fileName + "\" from folder \"" + folder + "\".");

        string mainFolder = folder.Split("\\")[0];
        CSystemFidsFolder@ mapsFolder = Fids::GetUserFolder(mainFolder);
        if (mapsFolder is null) {
            _Logging::Error("[GetMapFromFid] Failed to find " + mainFolder + " folder in Documents\\Trackmania.", true);
            return null;
        }

        Fids::UpdateTree(mapsFolder);

        CSystemFidFile@ mapFile = Fids::GetUser(folder + "\\" + fileName);
        if (mapFile is null) {
            _Logging::Error("[GetMapFromFid] Failed to find requested map file.", true);
            return null;
        }
        
        CMwNod@ nod = Fids::Preload(mapFile);
        if (nod is null) {
            _Logging::Error("[GetMapFromFid] Failed to preload " + fileName, true);
            return null;
        }
        
        CGameCtnChallenge@ map = cast<CGameCtnChallenge>(nod);
        if (map is null) {
            _Logging::Error("[GetMapFromFid] Failed to cast " + fileName + " to its class.", true);
            _Logging::Warn("[GetMapFromFid] Casting map to CGameCtnChallenge failed. File might not be a valid GBX map file");
            return null;
        }

        return map;
    }

    CGameCtnChallenge@ GetMapFromPath(const string &in path) {
        _Logging::Trace("[GetMapFromPath] Getting map from path \"" + path + "\".");

        if (!IO::FileExists(path)) {
            _Logging::Warn("[GetMapFromPath] Failed to find file in provided path. Make sure to use an absolute path!", true);
            return null;
        }
        
        if (!path.ToLower().EndsWith(".map.gbx")) {
            _Logging::Warn("[GetMapFromPath] The path \"" + path + "\" doesn't correspond to a GBX map file!", true);
            return null;
        }

        const string fileName = Path::GetFileName(path);

        CGameCtnChallenge@ cmap;

        // if map is in user folder, we can get it directly
        if (path.StartsWith(USER_FOLDER)) {
            _Logging::Debug("[GetMapFromPath] Map file \"" + fileName + "\" is in user folder. Skipping copy...");

            string folder = Path::GetDirectoryName(path.Replace(USER_FOLDER, ""));

            if (folder == "") {
                return null;
            } else if (folder.EndsWith("\\")) {
                folder = folder.SubStr(0, folder.Length - 1);
            }

            @cmap = TM::GetMapFromFid(fileName, folder);
        } else {
            _Logging::Debug("[GetMapFromPath] Map file " + fileName + " isn't in user folder. Copying...");

            if (!IO::FolderExists(TEMP_MAP_FOLDER)) {
                IO::CreateFolder(TEMP_MAP_FOLDER);
            }
            
            string newPath = TEMP_MAP_FOLDER + fileName;

            IO::Copy(path, newPath);
            @cmap = TM::GetMapFromFid(fileName);
            IO::Delete(newPath);
        }

        return cmap;
    }

    array<Map@> GetMapsFromFolder(const string &in path) {
        _Logging::Trace("[GetMapsFromFolder] Getting maps from folder \"" + path + "\".");

        array<Map@> maps;

        if (!IO::FolderExists(path)) {
            _Logging::Warn("[GetMapsFromFolder] Failed to find folder in provided path. Make sure to use an absolute path!", true);
            return maps;
        }

        array<string> files = IO::IndexFolder(path, false);

        uint start = Time::Now;

        for (uint i = 0; i < files.Length; i++) {
            if (Time::Now > start + MAX_FRAME_TIME) {
                start = Time::Now;
                yield();
            }

            if (!files[i].ToLower().EndsWith(".map.gbx")) continue;
            CGameCtnChallenge@ pathMap = GetMapFromPath(files[i].Replace("/", "\\"));

            if (pathMap !is null) {
                maps.InsertLast(Map(pathMap, files[i]));
            }
        }

        return maps;
    }
}
