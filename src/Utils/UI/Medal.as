namespace UI {
    // From Better TOTD by Xertrov https://github.com/XertroV/tm-better-totd
    const string UNPLAYED_ICON = "\\$444" + Icons::CircleO + " \\$z";
    const string PLAYED_ICON   = "\\$444" + Icons::Circle + " \\$z";
    const string BRONZE_ICON   = "\\$964" + Icons::Circle + " \\$z";
    const string SILVER_ICON   = "\\$899" + Icons::Circle + " \\$z";
    const string GOLD_ICON     = "\\$db4" + Icons::Circle + " \\$z";
    const string AT_ICON       = "\\$071" + Icons::Circle + " \\$z";

    const string RED_COLOR     = "\\$F77";
    const string BLUE_COLOR    = "\\$77F";
    const string GREY_COLOR    = "\\$888";

    string FormatMedal(int time, GameMode mode, Medals medal) {
        string icon = GetMedalIcon(medal);
        string formattedTime = FormatTime(time, mode);

        return icon + formattedTime;
    }

    string GetMedalIcon(Medals medal) {
        switch (medal) {
#if DEPENDENCY_WARRIORMEDALS
            case Medals::Warrior:
                return WarriorMedals::GetColorStr() + Icons::Circle + " \\$z";
#endif
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

    string GetTimeIcon(Map@ map, int time) {
        if ((map.GameMode == GameMode::Platform && time < 0) || (map.GameMode != GameMode::Platform && time <= 0)) {
            return UNPLAYED_ICON;
        }

#if DEPENDENCY_WARRIORMEDALS
        if (map.HasWarrior && time <= map.WarriorScore) {
            return WarriorMedals::GetColorStr() + Icons::Circle + " \\$z";
        }
#endif

        bool inverse = map.GameMode == GameMode::Stunt;

        if ((time >= map.AuthorScore && inverse) || (time <= map.AuthorScore && !inverse)) {
            return AT_ICON;
        }

        if ((time >= map.GoldScore && inverse) || (time <= map.GoldScore && !inverse)) {
            return GOLD_ICON;
        }

        if ((time >= map.SilverScore && inverse) || (time <= map.SilverScore && !inverse)) {
            return SILVER_ICON;
        }

        if ((time >= map.BronzeScore && inverse) || (time <= map.BronzeScore && !inverse)) {
            return BRONZE_ICON;
        }

        return PLAYED_ICON;
    }

    string FormatTime(int time, GameMode mode) {
        switch (mode) {
            case GameMode::Stunt:
                if (time < 1) return "-";

                return tostring(time) + " pts";
            case GameMode::Platform:
                if (time < 0) return "-";

                return tostring(time) + " respawns";
            case GameMode::Race:
            default:
                if (time < 1) {
                    return "-:--.---";
                } else if (uint(time) == uint(-1)) {
                    return "SECRET";
                }

                return Time::Format(time);
        }
    }

    void MedalsToolTip(Map@ map) {
        if (UI::BeginItemTooltip()) {
#if DEPENDENCY_WARRIORMEDALS
            if (map.HasWarrior) {
                UI::Text(FormatMedal(map.WarriorScore, map.GameMode, Medals::Warrior));
            }
#endif
            UI::Text(FormatMedal(map.AuthorScore, map.GameMode, Medals::Author));
            UI::Text(FormatMedal(map.GoldScore, map.GameMode, Medals::Gold));
            UI::Text(FormatMedal(map.SilverScore, map.GameMode, Medals::Silver));
            UI::Text(FormatMedal(map.BronzeScore, map.GameMode, Medals::Bronze));

            UI::EndTooltip();
        }
    }

    string FormatDelta(int medalTime, int pbTime, GameMode mode) {
        if (medalTime < 0 || pbTime < 0 || uint(pbTime) == uint(-1)) return "";

        int delta = medalTime - pbTime;

        switch (mode) {
            case GameMode::Stunt:
                if (delta > 0) {
                    return RED_COLOR + "\u2212" + delta;
                } else if (delta < 0) {
                    return BLUE_COLOR + "+" + Math::Abs(delta);
                } else {
                    return GREY_COLOR + "\u2212";
                }
            case GameMode::Platform:
                if (delta > 0) {
                    return BLUE_COLOR + "\u2212" + delta;
                } else if (delta < 0) {
                    return RED_COLOR + "+" + Math::Abs(delta);
                } else {
                    return GREY_COLOR + "\u2212";
                }
            case GameMode::Race:
            default:
                if (delta > 0) {
                    return BLUE_COLOR + "\u2212" + Time::Format(delta);
                } else if (delta < 0) {
                    return RED_COLOR + "+" + Time::Format(Math::Abs(delta));
                } else {
                    return GREY_COLOR + "-:--.---";
                }
        }
    }
}
