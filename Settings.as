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

[SettingsTab name="Dev" order="2" icon="Code"]
void RenderDev() {
    if (UI::Button("Reset to default")) {
        S_LogLevel = LogLevel::Info;
    }

    if (UI::BeginCombo("Log level", tostring(S_LogLevel))) {
        for (int i = 0; i <= LogLevel::Trace; i++) {
            if (UI::Selectable(tostring(LogLevel(i)), S_LogLevel == LogLevel(i))) {
                S_LogLevel = LogLevel(i);
            }
        }
        UI::EndCombo();
    }
}
