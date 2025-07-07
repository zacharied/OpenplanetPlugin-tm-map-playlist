class AddPlaylist: ModalDialog {
    string m_playlistName;

    AddPlaylist() {
        super("Add Playlist###AddPlaylist");
        m_size = vec2(700, 500);
    }

    void RenderDialog() override {
        array<string> keys = savedPlaylists.GetKeys();

        UI::AlignTextToFramePadding();

        UI::Text("Playlist name: ");

        UI::SameLine();

        UI::SetNextItemWidth(225);
        m_playlistName = UI::InputText("##PlaylistName", m_playlistName);

        bool nameExists = keys.Find(m_playlistName) != -1;

        if (nameExists) {
            UI::Text("\\$f90" + Icons::ExclamationTriangle + "\\$z A playlist with that name already exists!\nSaving will overwrite the previous playlist.");
        }

        vec2 region = UI::GetContentRegionAvail();

        if (UI::BeginChild("MapsChild", vec2(0, region.y - (40 * UI_SCALE)))) {
            UI::PushStyleVar(UI::StyleVar::IndentSpacing, 5);
            UI::PushStyleColor(UI::Col::HeaderHovered, vec4(0.3f, 0.3f, 0.3f, 0.8f));

            if (UI::TreeNode("Maps (" + playlist.Length + ")###Maps", UI::TreeNodeFlags::FramePadding | UI::TreeNodeFlags::SpanAvailWidth | UI::TreeNodeFlags::DefaultOpen)) {
                UI::PushTableVars();

                if (UI::BeginTable("AddPlaylistMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                    UI::TableSetupScrollFreeze(0, 1);
                    UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                    UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthFixed, columnWidths.Author);
                    UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed);
                    UI::TableHeadersRow();

                    UI::ListClipper clipper(playlist.Length);
                    while (clipper.Step()) {
                        for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, playlist.Length); i++) {
                            UI::PushID("AddMap" + i);

                            UI::TableNextRow();
                            UI::TableNextColumn();

                            Map@ map = playlist[i];

                            UI::AlignTextToFramePadding();
                            UI::Text(map.Name);

                            UI::TableNextColumn();
                            UI::Text(map.Author);

                            UI::TableNextColumn();
                            UI::Text(UI::FormatMedal(map.AuthorTime, map.GameMode, Medals::Author));
                            UI::MedalsToolTip(map);

                            UI::TableNextColumn();
                            if (UI::RedButton(Icons::TrashO)) {
                                playlist.DeleteMap(map);
                            }

                            UI::SetItemTooltip("Remove map");

                            UI::PopID();
                        }
                    }
                    UI::EndTable();
                }

                UI::PopTableVars();
                UI::TreePop();
            }
            UI::PopStyleColor();
            UI::PopStyleVar();
        }
        UI::EndChild();

        vec2 pos = UI::GetCursorPos();
        UI::SetCursorPos(vec2(region.x - 65 * UI_SCALE, pos.y));

        UI::BeginDisabled(m_playlistName == "");

        if (UI::GreenButton(Icons::FloppyO + " Save")) {
            Saves::SavePlaylist(m_playlistName, playlist.ToJson(), nameExists);
            m_playlistName = "";
            Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Save current playlist");
    }
}
