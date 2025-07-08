const vec4 DEFAULT_COLOR = vec4( 66/255.0f,  66/255.0f,  66/255.0f, 1);

class TmxTag {
    int ID;
    string Name;
    string Color;

    TmxTag(Json::Value@ json) {
        ID = json["TagId"];
        Name = json["Name"];
        Color = json["Color"];
    }

    Json::Value@ ToJson() {
        Json::Value json = Json::Object();

        json["TagId"] = ID;
        json["Name"] = Name;
        json["Color"] = Color;

        return json;
    }

    void Render() {
        vec4 color;

        if (S_ColoredTags && Text::TryParseHexColor(this.Color, color)) {
            Controls::Tag("\\$s" + this.Name, color);
        } else {
            Controls::Tag("\\$s" + this.Name, DEFAULT_COLOR);
        }
    }
}
