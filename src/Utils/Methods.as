string CleanMapType(const string &in mapType) {
    const int slashIndex = mapType.IndexOf("\\");

    if (slashIndex == -1) return mapType;

    return mapType.SubStr(slashIndex + 1);
}

Vistas GetVistaFromName(const string &in name) {
    for (uint i = 0; i < Vistas::Last; i++) {
        string vistaName = tostring(Vistas(i)).Replace("_", "").ToLower();

        if (vistaName == name.ToLower()) {
            return Vistas(i);
        }
    }

    return Vistas::Stadium;
}

string Pluralize(const string &in word, int count, const string &in suffix = "s") {
    if (count == 1) return word;

    return word + suffix;
}

string CleanPath(const string &in path) {
    return path.Replace("/", "\\").Replace("\"", "");
}

array<array<string>> Chunks(array<string> arr, uint maxLength) {
    if (maxLength == 0) {
        return {};
    }

    if (arr.Length <= maxLength) {
        return { arr };
    }

    array<array<string>> arrayChunks;

    for (uint i = 0; i < arr.Length; i += maxLength) {
        array<string> chunk;

        for (uint j = i; j < i + maxLength && j < arr.Length; j++) {
            chunk.InsertLast(arr[j]);
        }

        arrayChunks.InsertLast(chunk);
    }

    return arrayChunks;
}

string GetComboText(array<bool> values) {
    uint count = 0;

    for (uint i = 0; i < values.Length; i++) {
        if (values[i]) {
            count++;
        }
    }

    if (count == 0) {
        return "Select...";
    }

    return tostring(count) + " selected";
}

// don't use this if your JSON is not an object containing strings!
dictionary JsonToDict(const Json::Value@ json) {
    if (json.GetType() != Json::Type::Object) {
        _Logging::Error("[JsonToDict] Failed to convert JSON to dictionary: JSON is not an object.");
        _Logging::Debug("[JsonToDict] JSON: " + Json::Write(json));
        return {};
    }

    dictionary converted = dictionary();
    array<string> keys = json.GetKeys();

    for (uint i = 0; i < keys.Length; i++) {
        const Json::Value@ value = json[keys[i]];

        if (value.GetType() != Json::Type::String) {
            _Logging::Error("[JsonToDict] Unexpected value type when converting JSON to dictionary.");
            _Logging::Debug("[JsonToDict] JSON value: " + tostring(value.GetType()));
            continue;
        }

        converted.Set(keys[i], string(value));
    }

    return converted;
}
