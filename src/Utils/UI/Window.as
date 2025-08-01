namespace UI {
    void RenderMainWindow() {
        if (!showMainWindow) {
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

        UI::Begin(FULL_NAME, showMainWindow, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking);
        UI::BeginTabBar("WindowTabs", UI::TabBarFlags::FittingPolicyResizeDown);

        if (UI::BeginTabItem("Maps")) {
            UI::RenderSources();

            UI::SameLine();

            vec2 dimensions = UI::MeasureButton(Icons::Random);
            UI::BottomRightButtons(dimensions.x * 2, 2);

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
            if (UI::BeginTable("Maps", 11, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX | UI::TableFlags::SizingStretchSame | UI::TableFlags::Hideable)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthFixed, playlist.columnWidths.Author);
                UI::TableSetupColumn("URL", UI::TableColumnFlags::WidthFixed, playlist.columnWidths.Url);
                UI::TableSetupColumn("UID", UI::TableColumnFlags::WidthFixed, playlist.columnWidths.Uid);
                UI::TableSetupColumn("Mode", UI::TableColumnFlags::WidthFixed, 60 * UI_SCALE);
                UI::TableSetupColumn("Tags", UI::TableColumnFlags::WidthFixed, playlist.columnWidths.Tags);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, playlist.columnWidths.Medals);
                UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthFixed, 110 * UI_SCALE);
                UI::TableSetupColumn("Delta", UI::TableColumnFlags::WidthFixed, 90 * UI_SCALE);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthFixed);
                UI::TableHeadersRow();

                UI::TableSetColumnEnabled(1, S_MapName);
                UI::TableSetColumnEnabled(2, S_MapAuthor);
                UI::TableSetColumnEnabled(3, S_MapUrl);
                UI::TableSetColumnEnabled(4, S_MapUid);
                UI::TableSetColumnEnabled(5, S_MapGamemode);
                UI::TableSetColumnEnabled(6, S_MapTags);
                UI::TableSetColumnEnabled(7, S_MapMedals);
                UI::TableSetColumnEnabled(8, S_MapPb);
                UI::TableSetColumnEnabled(9, S_MapDelta);
                UI::TableSetColumnEnabled(10, S_MapButtons);

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
            UI::BeginDisabled(playlist.IsEmpty());

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

                UI::ListClipper clipper(savedPlaylists.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, savedPlaylists.Length); i++) {
                        UI::PushID("Playlist"+i);
                        MapPlaylist@ list = savedPlaylists[i];
                        UI::RenderPlaylist(list, i);
                        UI::PopID();
                    }
                }
                UI::EndTable();
            }
            UI::PopTableVars();
            UI::EndTabItem();
        }

        if (UI::BeginTabItem("Settings")) {
            UI::BeginTabBar("SettingsTabs", UI::TabBarFlags::FittingPolicyResizeDown);

            if (UI::BeginTabItem(Icons::Wrench + " General")) {
                RenderGeneralSettings();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem(Icons::List + " Playlist")) {
                RenderPlaylistSettings();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem(Icons::Eye + " Display")) {
                RenderDisplaySettings();
                UI::EndTabItem();
            }

            if (UI::BeginTabItem(Icons::Code + " Dev")) {
                RenderDevSettings();
                UI::EndTabItem();
            }

            UI::EndTabBar();
            UI::EndTabItem();
        }

        UI::EndTabBar();

        UI::End();

        UI::PopStyleColor(3);
        UI::PopStyleVar(4);
    }
}
