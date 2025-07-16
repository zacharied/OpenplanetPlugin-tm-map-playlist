const float MIN_AUTHOR = 90;
const float MIN_NAME = 120;

class MapColumns {
    float Name = MIN_NAME;
    float Author = MIN_AUTHOR;
    float URL;

    void Update(array<Map@> maps) {
        if (maps.IsEmpty()) {
            Reset();
            return;
        }

        for (uint i = 0; i < maps.Length; i++) {
            Map@ map = maps[i];

            Name = Math::Max(Name, Draw::MeasureString(map.Name).x);
            Author = Math::Max(Author, Draw::MeasureString(map.Author).x);
            URL = Math::Max(URL, Draw::MeasureString(map.URL).x);
        }
    }

    void Reset() {
        Name = MIN_NAME;
        Author = MIN_AUTHOR;
        URL = 0.0f;
    }
}
