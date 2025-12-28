class AddPlaylist: ModalDialog {
    string m_playlistName;

    AddPlaylist() {
        super("Add Playlist###AddPlaylist");
        this.m_size = vec2(700, 500);
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();

        UI::Text("Playlist name: ");

        UI::SameLine();

        UI::SetNextItemWidth(225);
        this.m_playlistName = UI::InputText("##PlaylistName", this.m_playlistName);

        bool nameExists = false;
        bool tooLong = this.m_playlistName.Length > 50;

        if (this.m_playlistName != "") {
            for (uint i = 0; i < savedPlaylists.Length; i++) {
                MapPlaylist@ list = savedPlaylists[i];
                if (list.Name == this.m_playlistName) {
                    nameExists = true;
                    break;
                }
            }

            if (nameExists) {
                Controls::FrameWarning(Icons::ExclamationTriangle + " A playlist with that name already exists!");
            }
        }

        if (tooLong) {
            Controls::FrameWarning(Icons::ExclamationTriangle + " Playlist name is too long! (Max 50 characters)");
        }

        vec2 region = UI::GetContentRegionAvail();

        if (UI::BeginChild("MapsChild", vec2(0, region.y - (40 * UI::GetScale())))) {
            UI::PushStyleVar(UI::StyleVar::IndentSpacing, 5);
            UI::PushStyleColor(UI::Col::HeaderHovered, vec4(0.3f, 0.3f, 0.3f, 0.8f));

            if (UI::TreeNode("Maps (" + playlist.Length + ")###Maps", UI::TreeNodeFlags::FramePadding | UI::TreeNodeFlags::SpanAvailWidth | UI::TreeNodeFlags::DefaultOpen)) {
                UI::PushTableVars();

                if (UI::BeginTable("AddPlaylistMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                    UI::TableSetupScrollFreeze(0, 1);
                    UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                    UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthFixed, playlist.columnWidths.Author);
                    UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI::GetScale());
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
                            UI::Text(UI::FormatMedal(map.AuthorScore, map.GameMode, Medals::Author));
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

        UI::BeginDisabled(this.m_playlistName == "" || nameExists || tooLong);

        UI::BottomRightButton(UI::MeasureButton(Icons::FloppyO + " Save").x);

        if (UI::GreenButton(Icons::FloppyO + " Save")) {
            MapPlaylist new = playlist;
            new.Name = this.m_playlistName;
            Saves::SavePlaylist(new);

            this.Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Save current playlist");
    }
}
