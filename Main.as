void Main() {
    if (!HAS_PERMISSIONS) {
        _Logging::Error("You don't have enough permissions to use this plugin!", true);

        Meta::Plugin@ self = Meta::ExecutingPlugin();
        Meta::UnloadPlugin(self);
    }

    Saves::LoadPlaylists();

    NadeoServices::AddAudience("NadeoLiveServices");

    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        yield();
    }

    TM::GetWeeklyShorts();
    TM::GetSeasonalCampaigns();
}

[Setting hidden]
bool showWindow = true;

void RenderMenu() {
    if (HAS_PERMISSIONS && UI::MenuItem(FULL_NAME, "", showWindow)) {
        showWindow = !showWindow;
    }
}

void Render() {
    if (!HAS_PERMISSIONS || !showWindow || (S_HideWithOP && !UI::IsOverlayShown()) || (S_HideWithGameUI && !UI::IsGameUIVisible())) {
        return;
    }

    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
    UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));

    UI::SetNextWindowSize(600, 400, UI::Cond::FirstUseEver);

    if (UI::Begin(FULL_NAME, showWindow, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking)) {
        UI::BeginTabBar("WindowTabs", UI::TabBarFlags::FittingPolicyResizeDown);

        if (UI::BeginTabItem("Maps")) {
            UI::RenderSources();

            UI::SameLine(0, 20);

            UI::PushStyleColor(UI::Col::Separator, vec4(0.25, 0.25, 0.25, 1));
            UI::Separator(UI::SeparatorFlags::Vertical, 3);
            UI::PopStyleColor();

            UI::SameLine(0, 20);

            S_Editor = UI::Checkbox("Load in Editor", S_Editor);

            UI::SameLine();

            vec2 pos = UI::GetCursorPos();
            UI::SetCursorPos(vec2(region.x - 120 * UI_SCALE, pos.y));

            UI::BeginDisabled(playlist.IsEmpty());

            if (UI::RedButton(Icons::TrashO + " Clear")) {
                playlist.Clear();
            }

            UI::SameLine();

            if (UI::Button(Icons::Random)) {
                playlist.Randomize();
            }

            UI::SetItemTooltip("Shuffle playlist");

            UI::EndDisabled();

            UI::PushTableVars();
            if (UI::BeginTable("Maps", 6, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX | UI::TableFlags::SizingStretchSame)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthStretch, 0.6);
                UI::TableSetupColumn("URL", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthFixed);
                UI::TableHeadersRow();

                UI::ListClipper clipper(playlist.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, playlist.Length); i++) {
                        UI::PushID("PlaylistMap"+i);
                        Map@ map = playlist[i];
                        UI::RenderMap(map, i);
                        UI::PopID();
                    }
                }
                UI::EndTable();
            }

            UI::PopTableVars();

            UI::EndTabItem();
        }

        if (UI::BeginTabItem("Playlists")) {
            array<string> keys = savedPlaylists.GetKeys();

            UI::BeginDisabled(playlist.Length == 0);

            if (UI::GreenButton(Icons::Plus + " New")) {
                Renderables::Add(AddPlaylist());
            }

            UI::SetItemTooltip("Save current playlist");

            UI::EndDisabled();

            UI::PushTableVars();
            if (UI::BeginTable("Playlists", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Map Count", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Created at", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthStretch);
                UI::TableHeadersRow();

                UI::ListClipper clipper(keys.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, keys.Length); i++) {
                        UI::PushID("Playlist"+i);
                        Json::Value@ list = savedPlaylists[keys[i]];
                        UI::RenderPlaylist(list, i);
                        UI::PopID();
                    }
                }
                UI::EndTable();
            }
            UI::PopTableVars();
            UI::EndTabItem();
        }

        UI::EndTabBar();

        
    }

    UI::End();
    UI::PopStyleVar(4);

    Renderables::Render();
}

bool held = false;

void OnKeyPress(bool down, VirtualKey key) {
    if (!HAS_PERMISSIONS || playlist.IsEmpty() || TM::IsLoadingMap()) return;

    if (!held && key == S_SwitchKey) {
        playlist.NextMap();
    }

    held = down;
}
