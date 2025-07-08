namespace UI {
    // From Better TOTD by Xertrov https://github.com/XertroV/tm-better-totd
    const string BRONZE_ICON = "\\$964" + Icons::Circle + " \\$z";
    const string SILVER_ICON = "\\$899" + Icons::Circle + " \\$z";
    const string GOLD_ICON = "\\$db4" + Icons::Circle + " \\$z";
    const string AT_ICON = "\\$071" + Icons::Circle + " \\$z";

    string FormatMedal(int time, GameMode mode, Medals medal) {
        string icon = GetMedalIcon(medal);
        string formattedTime = FormatTime(time, mode);

        return icon + formattedTime;
    }

    string GetMedalIcon(Medals medal) {
        switch (medal) {
            case Medals::Author:
                return AT_ICON;
            case Medals::Gold:
                return GOLD_ICON;
            case Medals::Silver:
                return SILVER_ICON;
            case Medals::Bronze:
                return BRONZE_ICON;
            default:
                return "";
        }
    }

    string FormatTime(int time, GameMode mode) {
        switch (mode) {
            case GameMode::Stunt:
                if (time < 1) return "-";

                return tostring(time) + " points";
            case GameMode::Platform:
                if (time < 0) return "-";

                return tostring(time) + " respawns";
            case GameMode::Race:
            default:
                if (time < 1) {
                    return "-:--.---";
                }

                return Time::Format(time);
        }
    }

    void MedalsToolTip(Map@ map) {
        if (UI::BeginItemTooltip()) {
            UI::Text(FormatMedal(map.AuthorTime, map.GameMode, Medals::Author));
            UI::Text(FormatMedal(map.GoldTime, map.GameMode, Medals::Gold));
            UI::Text(FormatMedal(map.SilverTime, map.GameMode, Medals::Silver));
            UI::Text(FormatMedal(map.BronzeTime, map.GameMode, Medals::Bronze));

            UI::EndTooltip();
        }
    }
}
