string CleanMapType(const string &in mapType) {
    const int slashIndex = mapType.IndexOf("\\");

    if (slashIndex == -1) return mapType;

    return mapType.SubStr(slashIndex + 1);
}

string Pluralize(const string &in word, int count, const string &in suffix = "s") {
    if (count == 1) return word;

    return word + suffix;
}

string CleanPath(const string &in path) {
    return path.Replace("/", "\\").Replace("\"", "");
}
