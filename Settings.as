[Setting hidden]
VirtualKey S_SwitchKey = VirtualKey(0);

[Setting hidden]
bool S_Editor = false;

[Setting hidden]
bool S_HideWithOP = true;

[Setting hidden]
bool S_HideWithGameUI = true;

[Setting hidden]
bool S_Loop = false;

[Setting hidden]
bool S_ColoredNames = true;

[Setting hidden]
bool S_ColoredTags = true;

[Setting hidden]
bool S_PlaylistsTab = true;

[Setting hidden]
bool S_SettingsTab = true;

[Setting hidden]
bool S_MapName = true;

[Setting hidden]
bool S_MapAuthor = true;

[Setting hidden]
bool S_MapUrl = true;

[Setting hidden]
bool S_MapGamemode = false;

[Setting hidden]
bool S_MapMedals = true;

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

[Setting hidden]
LogLevel S_LogLevel = LogLevel::Info;

[SettingsTab name="General" order="1" icon="Wrench"]
void RenderGeneral() {
    if (UI::Button("Reset to default")) {
        S_SwitchKey = VirtualKey(0);
    }

    UI::SetNextItemWidth(225);
    if (UI::BeginCombo("Switch Map Hotkey", S_SwitchKey == VirtualKey(0) ? "None" : tostring(S_SwitchKey))) {
        for (int i = 0; i <= 254; i++) {
            if (tostring(VirtualKey(i)) == tostring(i)) continue;

            if (UI::Selectable(tostring(VirtualKey(i)), S_SwitchKey == VirtualKey(i))) {
                S_SwitchKey = VirtualKey(i);
            }
        }
        UI::EndCombo();
    }
    UI::SettingDescription("Hotkey used to move to the next map.");

    S_Editor = UI::Checkbox("Load in editor", S_Editor);
    UI::SettingDescription("If enabled, maps will be loaded in the editor.");

    S_HideWithOP = UI::Checkbox("Show/Hide with Openplanet overlay", S_HideWithOP);

    S_HideWithGameUI = UI::Checkbox("Show/Hide with game UI", S_HideWithGameUI);

    S_Loop = UI::Checkbox("Loop playlist", S_Loop);
    UI::SettingDescription("When enabled, the playlist will start again after reaching the last map.");

    S_ColoredNames = UI::Checkbox("Display colored map names", S_ColoredNames);
}

[SettingsTab name="Tabs" order="2" icon="ThLarge"]
void RenderTabs() {
    if (UI::Button("Reset to default")) {
        S_PlaylistsTab = true;
        S_SettingsTab = true;
    }

    UI::BeginDisabled();
    UI::Checkbox("Maps", true);
    UI::EndDisabled();

    S_PlaylistsTab = UI::Checkbox("Playlists", S_PlaylistsTab);
    S_SettingsTab = UI::Checkbox("Settings", S_SettingsTab);
}

[SettingsTab name="Display" order="3" icon="Eye"]
void RenderDisplay() {
    if (UI::Button("Reset to default")) {
        S_MapName = true;
        S_MapAuthor = true;
        S_MapUrl = true;
        S_MapGamemode = false;
        S_MapMedals = true;
        S_MapButtons = true;

        S_PlaylistName = true;
        S_PlaylistMapCount = true;
        S_PlaylistDate = true;
        S_PlaylistButtons = true;
    }

    UI::SeparatorText("Maps");

    S_MapName = UI::Checkbox("Name##Map", S_MapName);
    S_MapAuthor = UI::Checkbox("Author##Map", S_MapAuthor);
    S_MapUrl = UI::Checkbox("URL##Map", S_MapUrl);
    S_MapGamemode = UI::Checkbox("Mode##Map", S_MapGamemode);
    S_MapMedals = UI::Checkbox("Medals##Map", S_MapMedals);
    S_MapButtons = UI::Checkbox("Buttons##Map", S_MapButtons);

    UI::SeparatorText("Playlists");

    S_PlaylistName = UI::Checkbox("Name##Playlist", S_PlaylistName);
    S_PlaylistMapCount = UI::Checkbox("Map Count##Playlist", S_PlaylistMapCount);
    S_PlaylistDate = UI::Checkbox("Created at##Playlist", S_PlaylistDate);
    S_PlaylistButtons = UI::Checkbox("Buttons##Playlist", S_PlaylistButtons);
}

[SettingsTab name="Dev" order="4" icon="Code"]
void RenderDev() {
    if (UI::Button("Reset to default")) {
        S_LogLevel = LogLevel::Info;
    }

    UI::SetNextItemWidth(225);
    if (UI::BeginCombo("Log level", tostring(S_LogLevel))) {
        for (int i = 0; i <= LogLevel::Trace; i++) {
            if (UI::Selectable(tostring(LogLevel(i)), S_LogLevel == LogLevel(i))) {
                S_LogLevel = LogLevel(i);
            }
        }
        UI::EndCombo();
    }
}
