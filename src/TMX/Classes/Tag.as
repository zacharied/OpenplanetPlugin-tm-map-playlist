const vec4 DEFAULT_COLOR = vec4( 66/255.0f,  66/255.0f,  66/255.0f, 1);

class TmxTag {
    int ID;
    string Name;
    string Color;

    TmxTag(Json::Value@ json) {
        // Tags endpoint and map/mappack endpoints use different keys
        if (json.HasKey("TagId")) {
            this.ID = json["TagId"];
        } else {
            this.ID = json["ID"];
        }

        this.Name = json["Name"];
        this.Color = json["Color"];
    }

    Json::Value@ ToJson() {
        Json::Value json = Json::Object();

        json["TagId"] = this.ID;
        json["ID"] = this.ID;
        json["Name"] = this.Name;
        json["Color"] = this.Color;

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

    bool opEquals(TmxTag@ b) {
        return this.ID == b.ID;
    }
}
