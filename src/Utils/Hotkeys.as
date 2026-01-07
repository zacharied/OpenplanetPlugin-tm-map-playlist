namespace _Hotkeys {
    enum HotkeySetting {
        None,
        Switch,
        MainWindow,
        Timer
    }

    HotkeySetting DetectingSetting = HotkeySetting::None;

    bool get_ListeningForKey() {
        return DetectingSetting != HotkeySetting::None;
    }

    void StopListeningForKey() {
        DetectingSetting = HotkeySetting::None;
    }

    bool get_ListeningForSwitchKey() { return DetectingSetting == HotkeySetting::Switch; }
    void set_ListeningForSwitchKey(bool detect) { DetectingSetting = detect ? HotkeySetting::Switch : HotkeySetting::None; }

    bool get_ListeningForWindowKey() { return DetectingSetting == HotkeySetting::MainWindow; }
    void set_ListeningForWindowKey(bool detect) { DetectingSetting = detect ? HotkeySetting::MainWindow : HotkeySetting::None; }

    bool get_ListeningForTimerKey() { return DetectingSetting == HotkeySetting::Timer; }
    void set_ListeningForTimerKey(bool detect) { DetectingSetting = detect ? HotkeySetting::Timer : HotkeySetting::None; }

    string GetKeyName(VirtualKey key) {
        if (key == VirtualKey(0)) {
            return "None";
        }

        const string name = tostring(key);

        if (name == tostring(int(key))) {
            return "";
        }

        return name;
    }

    bool IsKeyUsed(VirtualKey key) {
        if (key == VirtualKey(0)) {
            return false;
        }

        array<VirtualKey> usedKeys = {
            S_SwitchKey,
            S_WindowKey,
            S_TimerKey
        };

        return usedKeys.Find(key) > -1;
    }

    void RemoveHotkey(VirtualKey key) {
        if (!IsKeyUsed(key)) {
            return;
        }

        _Logging::Trace("[RemoveHotkey] Removing hotkey " + tostring(key));

        if (S_SwitchKey == key) {
            S_SwitchKey = VirtualKey(0);
        } else if (S_WindowKey == key) {
            S_WindowKey = VirtualKey(0);
        } else if (S_TimerKey == key) {
            S_TimerKey = VirtualKey(0);
        }
    }

    void AssignHotkey(VirtualKey key) {
        if (!ListeningForKey) {
            return;
        }

        _Logging::Trace("[AssignHotkey] Assigning hotkey " + tostring(key));

        RemoveHotkey(key);

        switch (DetectingSetting) {
            case HotkeySetting::Switch:
                S_SwitchKey = key;
                break;
            case HotkeySetting::MainWindow:
                S_WindowKey = key;
                break;
            case HotkeySetting::Timer:
                S_TimerKey = key;
                break;
            default:
                break;
        }

        StopListeningForKey();
    }

    void RenderHotkeyCombo(const string &in label, VirtualKey currentKey) {
        UI::SetNextItemWidth(175);

        if (UI::BeginCombo(label, GetKeyName(currentKey))) {
            for (int i = 0; i <= 254; i++) {
                VirtualKey key = VirtualKey(i);
                string keyName = GetKeyName(key);
                bool taken = key != currentKey && IsKeyUsed(key);

                if (keyName == "") {
                    continue;
                }

                UI::BeginDisabled(taken);

                if (UI::Selectable(keyName, currentKey == key)) {
                    AssignHotkey(key);
                }

                if (taken) {
                    UI::SetItemTooltip("Key already used for a different setting!");
                }

                UI::EndDisabled();
            }

            UI::EndCombo();
        }
    }
}
