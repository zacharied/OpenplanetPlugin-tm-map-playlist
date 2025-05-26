string CleanMapType(const string &in mapType) {
    const int slashIndex = mapType.IndexOf("\\");

    if (slashIndex == -1) return mapType;

    return mapType.SubStr(slashIndex + 1);
}