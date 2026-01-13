namespace Timer {
    string g_currentUid = "";
    uint g_lastUpdate = 0;
    uint g_timer = 0;
    bool g_paused = false;

    void Render() {
        if (!g_showTimer) {
            return;
        }

        if (UI::Begin("##Timer", UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize)) {
            UI::PushFontSize(24);

            UI::BeginDisabled(Paused);

            UI::AlignTextToFramePadding();
            UI::Text(Time::Format(TimeLeft, false));

            UI::EndDisabled();
    
            UI::SameLine();

            UI::Separator(UI::SeparatorFlags::Vertical);

            UI::SameLine();

            UI::BeginDisabled(playlist.currentMap is null || TM::IsLoadingMap() || TM::InEditor() || !TM::InMap());
    
            if (UI::Button(Paused ? Icons::Play : Icons::Pause)) {
                Toggle();
            }

            UI::SetItemTooltip(Paused ? "Resume" : "Pause");

            UI::EndDisabled();

            UI::SameLine();

            if (UI::Button(Icons::Refresh)) {
                Reset();
            }

            UI::SetItemTooltip("Reset timer");

            UI::PopFontSize();
        }

        UI::End();
    }

    void Reset() {
        TimeSpent = 0;
        g_lastUpdate = Time::Now;
    }

    uint get_TimeLimit() {
        return S_TimeLimit * 1000;
    }

    uint get_TimeLeft() {
        return Math::Max(TimeLimit - TimeSpent, 0);
    }

    uint get_TimeSpent() {
        return g_timer;
    }

    void set_TimeSpent(uint n) {
        g_timer = Math::Clamp(n, 0, TimeLimit);
    }

    bool get_Paused() { 
        return g_paused;
    }

    void Pause()  { g_paused = true; }
    void Resume() { g_paused = false; }
    void Toggle() { g_paused = !g_paused; }
    
    void Update() {
        if (!S_Timer || TM::IsLoadingMap() || TM::InEditor() || !TM::InCurrentMap() || TM::IsPauseMenuDisplayed()) {
            g_lastUpdate = Time::Now;
            return;
        }

        CTrackMania@ app = cast<CTrackMania>(GetApp());

        if (app.RootMap.IdName != g_currentUid) {
            g_currentUid = app.RootMap.IdName;
            Reset();
            Resume();
        } else if (!Paused && TM::InCurrentMap()) {
            uint delta = Time::Now - g_lastUpdate;
            TimeSpent += delta;

            if (TimeSpent >= TimeLimit) {
                Pause();

                if (playlist.Length == 1) {
                    TM::ClosePauseMenu();
                    app.BackToMainMenu();
                    UI::ShowNotification(PLUGIN_NAME, "Timer is up! Quitting to the main menu...");
                } else {
                    playlist.NextMap();
                    UI::ShowNotification(PLUGIN_NAME, "Timer is up! Switching to the next map...");
                }
            }
        }

        g_lastUpdate = Time::Now;
    }
}
