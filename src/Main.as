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
    UI::PushStyleColor(UI::Col::TabActive, vec4(0.45, 0.45, 0.45, 1.0));
    UI::PushStyleColor(UI::Col::TabHovered, vec4(0.35, 0.35, 0.35, 1));
    UI::PushStyleColor(UI::Col::Tab, vec4(0.25, 0.25, 0.25, 1));

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

            S_Editor = UI::Checkbox(" Load in Editor", S_Editor);

            UI::SameLine();

            vec2 region = UI::GetContentRegionAvail();
            vec2 pos = UI::GetCursorPos();
            vec2 dimensions = UI::MeasureButton(Icons::Random);
            float itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;
            float newPos = Math::Max(region.x - (dimensions.x * 2) - (itemSpacing * 3), 0.0);
            UI::SetCursorPosX(pos.x + newPos);

            UI::BeginDisabled(playlist.IsEmpty());

            if (UI::Button(Icons::Random)) {
                playlist.Randomize();
            }

            UI::SetItemTooltip("Shuffle playlist");

            UI::SameLine();

            if (UI::RedButton(Icons::TrashO)) {
                playlist.Clear();
            }

            UI::SetItemTooltip("Clear playlist");

            UI::EndDisabled();

            UI::PushTableVars();
            if (UI::BeginTable("Maps", 7, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX | UI::TableFlags::SizingStretchSame | UI::TableFlags::Hideable)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthFixed, columnWidths.Name);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthFixed, columnWidths.Author);
                UI::TableSetupColumn("URL", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Mode", UI::TableColumnFlags::WidthFixed, 90 * UI_SCALE);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthFixed);
                UI::TableHeadersRow();

                UI::TableSetColumnEnabled(1, S_MapName);
                UI::TableSetColumnEnabled(2, S_MapAuthor);
                UI::TableSetColumnEnabled(3, S_MapUrl);
                UI::TableSetColumnEnabled(4, S_MapGamemode);
                UI::TableSetColumnEnabled(5, S_MapMedals);
                UI::TableSetColumnEnabled(6, S_MapButtons);

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

        if (S_PlaylistsTab && UI::BeginTabItem("Playlists")) {
            array<string> keys = savedPlaylists.GetKeys();

            UI::BeginDisabled(playlist.Length == 0);

            if (UI::GreenButton(Icons::Plus + " New")) {
                Renderables::Add(AddPlaylist());
            }

            UI::SetItemTooltip("Save current playlist");

            UI::EndDisabled();

            UI::PushTableVars();
            if (UI::BeginTable("Playlists", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX | UI::TableFlags::Hideable)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Map Count", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Created at", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthStretch);
                UI::TableHeadersRow();

                UI::TableSetColumnEnabled(1, S_PlaylistName);
                UI::TableSetColumnEnabled(2, S_PlaylistMapCount);
                UI::TableSetColumnEnabled(3, S_PlaylistDate);
                UI::TableSetColumnEnabled(4, S_PlaylistButtons);

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

        if (S_SettingsTab && UI::BeginTabItem("Settings")) {
            UI::BeginTabBar("SettingsTabs", UI::TabBarFlags::FittingPolicyResizeDown);

            if (UI::BeginTabItem(Icons::Wrench + " General")) {
                RenderGeneral();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem(Icons::ThLarge + " Tabs")) {
                RenderTabs();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem(Icons::Eye + " Display")) {
                RenderDisplay();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem(Icons::Code + " Dev")) {
                RenderDev();
                UI::EndTabItem();
            }

            UI::EndTabBar();
            UI::EndTabItem();
        }


        UI::EndTabBar();
    }

    UI::End();
    UI::PopStyleColor(3);
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
