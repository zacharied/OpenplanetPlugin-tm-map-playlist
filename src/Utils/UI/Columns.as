const float MIN_AUTHOR = 90;
const float MIN_NAME = 120;
const float MIN_MEDALS = 60;
const float MIN_TAGS = 40;

class MapColumns {
    float Name = MIN_NAME;
    float Author = MIN_AUTHOR;
    float Url;
    float Uid;
    float Tags = MIN_TAGS;
    float Medals = MIN_MEDALS;

    void Update(array<Map@> maps) {
        Reset();

        uint start = Time::Now;

        foreach (Map@ map : maps) {
            if (Time::Now > start + MAX_FRAME_TIME) {
                start = Time::Now;
                yield();
            }

            Name = Math::Max(Name, Draw::MeasureString(map.Name).x);
            Author = Math::Max(Author, Draw::MeasureString(map.Author).x);
            Url = Math::Max(Url, Draw::MeasureString(map.Url).x);
            Uid = Math::Max(Uid, Draw::MeasureString(map.Uid).x);
            Medals = Math::Max(Medals, Draw::MeasureString(UI::FormatMedal(map.AuthorScore, map.GameMode, Medals::Author)).x + 8);

            float itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;
            float tagsSize = 0.0;

            foreach (TMX::Tag@ tag : map.Tags) {
                tagsSize += Draw::MeasureString(tag.Name).x + 16;
                tagsSize += itemSpacing;
            }

            // Button to add or remove tags
            tagsSize += Draw::MeasureString(Icons::Plus).x;

            Tags = Math::Max(Tags, tagsSize);
        }
    }

    void Reset() {
        Name = MIN_NAME;
        Author = MIN_AUTHOR;
        Url = 0.0f;
        Uid = 0.0f;
        Tags = MIN_TAGS;
        Medals = MIN_MEDALS;
    }
}

class PlaylistColumns {
    float Name = MIN_NAME;
    float Tags = MIN_TAGS;

    void Update(array<MapPlaylist@> playlists) {
        Reset();

        uint start = Time::Now;

        foreach (MapPlaylist@ list : playlists) {
            if (Time::Now > start + MAX_FRAME_TIME) {
                start = Time::Now;
                yield();
            }

            Name = Math::Max(Name, Draw::MeasureString(list.Name).x);

            float itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;
            float tagsSize = 0.0;

            foreach (TMX::Tag@ tag : list.Tags) {
                tagsSize += Draw::MeasureString(tag.Name).x + 16;
                tagsSize += itemSpacing;
            }

            tagsSize += Draw::MeasureString(Icons::Plus).x;
            Tags = Math::Max(Tags, tagsSize);
        }
    }

    void Reset() {
        Name = MIN_NAME;
        Tags = MIN_TAGS;
    }
}
