namespace Cache {
    dictionary AuthorNames = {
        { "d2372a08-a8a1-46cb-97fb-23a161d85ad0", "Nadeo"} // Maps uploaded by the old Nadeo account return an empty string for the Author
    };

    dictionary Maps;

    string GetName(const string &in authorId) {
        string name;

        if (AuthorNames.Get(authorId, name)) {
            return name;
        }

#if DEPENDENCY_NADEOSERVICES
        name = NadeoServices::GetDisplayNameAsync(authorId);
        AuthorNames.Set(authorId, name);
#endif

        return name;
    }

    void SetName(const string &in name, const string &in authorId) {
        if (!AuthorNames.Exists(authorId) || string(AuthorNames[authorId]) == "") {
            AuthorNames.Set(authorId, name);
        }
    }

    Map@ GetMap(const string &in mapUid) {
        if (!Maps.Exists(mapUid)) {
            return null;
        }

        Json::Value@ json = cast<Json::Value>(Maps[mapUid]);

        return Map(json);
    }

    void SetMap(Map@ map) {
        if (!Maps.Exists(map.UID)) {
            Maps.Set(map.UID, map.ToJson());
        }
    }
}
