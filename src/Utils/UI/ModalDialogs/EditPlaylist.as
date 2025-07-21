class EditPlaylist: ModalDialog {
    MapPlaylist oldList;
    string oldName;
    string m_playlistName;

    EditPlaylist(MapPlaylist@ list) {
        super("Edit Playlist###EditPlaylist");
        this.m_size = vec2(700, 500);

        this.oldName = list.Name;
        this.m_playlistName = oldName;
        this.oldList = list;
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();

        UI::Text("Playlist name: ");

        UI::SameLine();

        UI::SetNextItemWidth(225);
        this.m_playlistName = UI::InputText("##PlaylistName", this.m_playlistName);

        vec2 region = UI::GetContentRegionAvail();

        if (UI::BeginChild("MapsChild", vec2(0, region.y - (40 * UI_SCALE)))) {
            UI::PushStyleVar(UI::StyleVar::IndentSpacing, 5);
            UI::PushStyleColor(UI::Col::HeaderHovered, vec4(0.3f, 0.3f, 0.3f, 0.8f));

            if (UI::TreeNode("Maps (" + this.oldList.Length + ")###Maps", UI::TreeNodeFlags::FramePadding | UI::TreeNodeFlags::SpanAvailWidth | UI::TreeNodeFlags::DefaultOpen)) {
                UI::PushTableVars();

                if (UI::BeginTable("EditPlaylistMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                    UI::TableSetupScrollFreeze(0, 1);
                    UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                    UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthFixed, this.oldList.columnWidths.Author);
                    UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed);
                    UI::TableHeadersRow();

                    UI::ListClipper clipper(this.oldList.Length);
                    while (clipper.Step()) {
                        for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, this.oldList.Length); i++) {
                            UI::PushID("EditMap" + i);

                            UI::TableNextRow();
                            UI::TableNextColumn();

                            Map@ map = this.oldList[i];

                            UI::AlignTextToFramePadding();
                            UI::Text(map.Name);

                            UI::TableNextColumn();
                            UI::Text(map.Author);

                            UI::TableNextColumn();
                            UI::Text(UI::FormatMedal(map.AuthorScore, map.GameMode, Medals::Author));
                            UI::MedalsToolTip(map);

                            UI::TableNextColumn();
                            if (UI::RedButton(Icons::TrashO)) {
                                this.oldList.DeleteMap(map);
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

        UI::BeginDisabled(this.m_playlistName == "" || this.oldList.IsEmpty());

        UI::BottomRightButton(UI::MeasureButton(Icons::FloppyO + " Save").x);

        if (UI::GreenButton(Icons::FloppyO + " Save")) {
            this.oldList.Name = this.m_playlistName;
            Saves::EditPlaylist(this.oldName, this.oldList);

            this.Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Save current playlist");
    }
}
