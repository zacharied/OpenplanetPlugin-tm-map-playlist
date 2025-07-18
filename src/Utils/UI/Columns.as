const float MIN_AUTHOR = 90;
const float MIN_NAME = 120;

class MapColumns {
    float Name = MIN_NAME;
    float Author = MIN_AUTHOR;
    float Url;

    void Update(array<Map@> maps) {
        if (maps.IsEmpty()) {
            Reset();
            return;
        }

        for (uint i = 0; i < maps.Length; i++) {
            Map@ map = maps[i];

            Name = Math::Max(Name, Draw::MeasureString(map.Name).x);
            Author = Math::Max(Author, Draw::MeasureString(map.Author).x);
            Url = Math::Max(Url, Draw::MeasureString(map.Url).x);
        }
    }

    void Reset() {
        Name = MIN_NAME;
        Author = MIN_AUTHOR;
        Url = 0.0f;
    }
}
