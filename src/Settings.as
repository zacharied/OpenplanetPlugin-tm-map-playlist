// --- General ---

[Setting hidden]
bool S_HideWithOP = true;

[Setting hidden]
bool S_HideWithGameUI = true;

// --- Playlist ---

[Setting hidden]
VirtualKey S_SwitchKey = VirtualKey(0);

[Setting hidden]
bool S_Editor = false;

[Setting hidden]
bool S_Loop = false;

[Setting hidden]
bool S_SwitchOnMedal = false;

[Setting hidden]
Medals S_GoalMedal = Medals::Author;

// --- Display ---

[Setting hidden]
bool S_ColoredNames = true;

[Setting hidden]
bool S_ColoredTags = true;

[Setting hidden]
bool S_MapThumbnail = true;

[Setting hidden]
Medals S_MainMedal = Medals::Author;

[Setting hidden]
bool S_MapName = true;

[Setting hidden]
bool S_MapAuthor = true;

[Setting hidden]
bool S_MapUrl = false;

[Setting hidden]
bool S_MapUid = false;

[Setting hidden]
bool S_MapGamemode = false;

[Setting hidden]
bool S_MapTags = true;

[Setting hidden]
bool S_MapMedals = true;

[Setting hidden]
bool S_MapPb = true;

[Setting hidden]
bool S_MapDelta = true;

[Setting hidden]
bool S_MapButtons = true;

[Setting hidden]
bool S_PlaylistName = true;

[Setting hidden]
bool S_PlaylistMapCount = true;

[Setting hidden]
bool S_PlaylistDate = true;

[Setting hidden]
bool S_PlaylistButtons = true;

// --- Dev ---

[Setting hidden]
LogLevel S_LogLevel = LogLevel::Info;

[Setting hidden]
bool S_SkipLoad = false;

[SettingsTab name="General" order="1" icon="Wrench"]
void RenderGeneralSettings() {
    UI::BeginChild("GeneralSettings");

    if (UI::Button("Reset to default")) {
        S_HideWithOP = true;
        S_HideWithGameUI = true;
    }

    S_HideWithOP = UI::Checkbox("Show/Hide with Openplanet overlay", S_HideWithOP);
    S_HideWithGameUI = UI::Checkbox("Show/Hide with game UI", S_HideWithGameUI);

    UI::EndChild();
}

[SettingsTab name="Playlist" order="2" icon="List"]
void RenderPlaylistSettings() {
    UI::BeginChild("PlaylistSettings");

    if (UI::Button("Reset to default")) {
        S_Editor = false;
        S_Loop = false;
        S_SwitchKey = VirtualKey(0);
        S_SwitchOnMedal = false;
        S_GoalMedal = Medals::Author;
    }

    UI::SetNextItemWidth(175);
    if (UI::BeginCombo("Switch Map Hotkey", S_SwitchKey == VirtualKey(0) ? "None" : tostring(S_SwitchKey))) {
        for (int i = 0; i <= 254; i++) {
            if (tostring(VirtualKey(i)) == tostring(i)) continue;

            if (UI::Selectable(tostring(VirtualKey(i)), S_SwitchKey == VirtualKey(i))) {
                S_SwitchKey = VirtualKey(i);
            }
        }
        UI::EndCombo();
    }
    UI::SettingDescription("Hotkey to switch to the next map.");

    S_Editor = UI::Checkbox("Load in editor", S_Editor);
    UI::SettingDescription("If enabled, maps will be loaded in the editor.");

    S_Loop = UI::Checkbox("Loop playlist", S_Loop);
    UI::SettingDescription("When enabled, the playlist will start again after reaching the last map.");

    S_SwitchOnMedal = UI::Checkbox("Auto switch on medal", S_SwitchOnMedal);
    string medalText = "When enabled, the plugin will automatically switch to the next map after reaching the selected medal.";
#if DEPENDENCY_WARRIORMEDALS
    medalText += "\n\nIf a map doesn't have a Warrior time, it will default to the Author medal instead.";
#endif
    medalText += "\n\nNOTE: Doesn't work in the editor or in maps from unknown sources.";

    UI::SettingDescription(medalText);


    if (S_SwitchOnMedal) {
        UI::SetNextItemWidth(175);
        if (UI::BeginCombo("Goal medal", tostring(S_GoalMedal))) {
            for (int i = 0; i < Medals::Last; i++) {
                if (UI::Selectable(tostring(Medals(i)), S_GoalMedal == Medals(i))) {
                    S_GoalMedal = Medals(i);
                }
            }
            UI::EndCombo();
        }
    }

    UI::EndChild();
}

[SettingsTab name="Display" order="3" icon="Eye"]
void RenderDisplaySettings() {
    UI::BeginChild("DisplaySettings");

    if (UI::Button("Reset to default")) {
        S_ColoredNames = true;
        S_ColoredTags = true;
        S_MapThumbnail = true;

        S_MainMedal = Medals::Author;

        S_MapName = true;
        S_MapAuthor = true;
        S_MapUrl = false;
        S_MapUid = false;
        S_MapGamemode = false;
        S_MapTags = true;
        S_MapMedals = true;
        S_MapPb = true;
        S_MapDelta = true;
        S_MapButtons = true;

        S_PlaylistName = true;
        S_PlaylistMapCount = true;
        S_PlaylistDate = true;
        S_PlaylistButtons = true;
    }

    S_ColoredNames = UI::Checkbox("Display colored map names", S_ColoredNames);
    S_ColoredTags = UI::Checkbox("Use TMX colors for map tags", S_ColoredTags);
    UI::SettingDescription("When disabled, map tags will use the default gray background color instead of the colors provided by TMX");
    S_MapThumbnail = UI::Checkbox("Display map thumbnail when hovering its name", S_MapThumbnail);

    UI::PushFontSize(21);
    UI::SeparatorText("Maps");
    UI::PopFontSize();

    S_MapName = UI::Checkbox("Name##Map", S_MapName);
    S_MapAuthor = UI::Checkbox("Author##Map", S_MapAuthor);
    S_MapUrl = UI::Checkbox("URL##Map", S_MapUrl);
    S_MapUid = UI::Checkbox("UID##Map", S_MapUid);
    S_MapTags = UI::Checkbox("TMX Tags##Map", S_MapTags);
    S_MapGamemode = UI::Checkbox("Mode##Map", S_MapGamemode);
    S_MapMedals = UI::Checkbox("Medals##Map", S_MapMedals);
    S_MapPb = UI::Checkbox("PB##Map", S_MapPb);
    S_MapDelta = UI::Checkbox("Delta##Map", S_MapDelta);
    S_MapButtons = UI::Checkbox("Buttons##Map", S_MapButtons);

    UI::NewLine();

    UI::SetNextItemWidth(145);
    if (UI::BeginCombo("Main medal", tostring(S_MainMedal))) {
        for (int i = 0; i < Medals::Last; i++) {
            if (UI::Selectable(tostring(Medals(i)), S_MainMedal == Medals(i))) {
                S_MainMedal = Medals(i);
            }
        }
        UI::EndCombo();
    }

    string settingText = "The medal shown in the Medals column and used to calculate the delta to your PB.";
#if DEPENDENCY_WARRIORMEDALS
    settingText += "\n\nIf a map doesn't have a Warrior time, it will default to the Author medal instead.";
#endif
    UI::SettingDescription(settingText);

    UI::PushFontSize(21);
    UI::SeparatorText("Playlists");
    UI::PopFontSize();

    S_PlaylistName = UI::Checkbox("Name##Playlist", S_PlaylistName);
    S_PlaylistMapCount = UI::Checkbox("Map Count##Playlist", S_PlaylistMapCount);
    S_PlaylistDate = UI::Checkbox("Created at##Playlist", S_PlaylistDate);
    S_PlaylistButtons = UI::Checkbox("Buttons##Playlist", S_PlaylistButtons);

    UI::EndChild();
}

[SettingsTab name="Dev" order="4" icon="Code"]
void RenderDevSettings() {
    UI::BeginChild("DevSettings");

    if (UI::Button("Reset to default")) {
        S_LogLevel = LogLevel::Info;
        S_SkipLoad = false;
    }

    UI::SetNextItemWidth(175);
    if (UI::BeginCombo("Log level", tostring(S_LogLevel))) {
        for (int i = 0; i <= LogLevel::Trace; i++) {
            if (UI::Selectable(tostring(LogLevel(i)), S_LogLevel == LogLevel(i))) {
                S_LogLevel = LogLevel(i);
            }
        }
        UI::EndCombo();
    }

    UI::PushFontSize(21);
    UI::SeparatorText("Data");
    UI::PopFontSize();

    S_SkipLoad = UI::Checkbox("Skip loading data", S_SkipLoad);
    UI::SettingDescription("Skip loading seasonal campaigns, weekly shorts, favorites, and TOTDs.\n\nPBs will still be loaded");

    if (UI::OrangeButton(Icons::Refresh + " Reload Seasonal Campaigns")) {
        SEASONAL_CAMPAIGNS.RemoveRange(0, SEASONAL_CAMPAIGNS.Length);
        startnew(TM::GetSeasonalCampaigns);
    }

    if (UI::OrangeButton(Icons::Refresh + " Reload Weekly Shorts")) {
        WEEKLY_SHORTS.RemoveRange(0, WEEKLY_SHORTS.Length);
        startnew(TM::GetWeeklyShorts);
    }

    if (UI::OrangeButton(Icons::Refresh + " Reload Favorites")) {
        FAVORITES.RemoveRange(0, FAVORITES.Length);
        startnew(TM::GetFavorites);
    }

    if (UI::OrangeButton(Icons::Refresh + " Reload TOTDs")) {
        TOTD_MONTHS.RemoveRange(0, TOTD_MONTHS.Length);
        startnew(TM::GetTOTDMonths);
    }

    UI::PushFontSize(21);
    UI::SeparatorText("Cache");
    UI::PopFontSize();

    if (UI::RedButton(Icons::TrashO + " Clear map cache")) {
        Cache::ClearMapCache();
    }

    UI::EndChild();
}
