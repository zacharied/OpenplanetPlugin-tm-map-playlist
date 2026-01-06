namespace Timer {
    uint timer = 0;
    uint lastUpdate = 0;
    bool paused = false;
    string lastMap = "";

    void Render() {
        if (!showTimer) {
            return;
        }

        if (UI::Begin("##Timer", UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoResize | UI::WindowFlags::AlwaysAutoResize)) {
            UI::PushFontSize(21);

            UI::AlignTextToFramePadding();
            UI::Text(Time::Format(TimeLeft, false));
    
            UI::SameLine();

            UI::BeginDisabled(playlist.currentMap is null || TM::IsLoadingMap() || TM::InEditor() || !TM::InMap());
    
            if (UI::Button(paused ? Icons::Play : Icons::Pause)) {
                paused = !paused;
            }

            UI::SetItemTooltip(paused ? "Resume" : "Pause");

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
        timer = 0;
        lastUpdate = Time::Now;
    }

    uint get_TimeLimit() {
        return S_TimeLimit * 1000;
    }

    uint get_TimeLeft() {
        return Math::Max(TimeLimit - timer, 0);
    }
    
    void Update() {
        if (!S_Timer || TM::IsLoadingMap() || TM::InEditor() || !TM::InCurrentMap() || TM::IsPauseMenuDisplayed()) {
            lastUpdate = Time::Now;
            return;
        }

        CTrackMania@ app = cast<CTrackMania>(GetApp());

        if (app.RootMap.IdName != lastMap) {
            lastMap = app.RootMap.IdName;
            Reset();
            paused = false;
        } else if (!paused && TM::InCurrentMap()) {
            uint delta = Time::Now - lastUpdate;
            timer += delta;

            if (timer >= TimeLimit) {
                paused = true;

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

        lastUpdate = Time::Now;
    }
}
