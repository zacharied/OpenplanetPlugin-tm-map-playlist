class EditPlaylist: ModalDialog {
    MapPlaylist m_oldList;
    string m_oldName;
    string m_playlistName;
    string m_tagSearch;

    EditPlaylist(MapPlaylist@ list) {
        super("Edit Playlist###EditPlaylist");
        this.m_size = vec2(700, 500);

        this.m_oldName = list.Name;
        this.m_playlistName = list.Name;
        this.m_oldList = list;
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();

        UI::Text("Playlist name: ");

        UI::SameLine();

        UI::SetNextItemWidth(225);
        this.m_playlistName = UI::InputText("##PlaylistName", this.m_playlistName);

        bool nameExists = false;
        bool tooLong = this.m_playlistName.Length > 50;

        if (this.m_playlistName != "" && this.m_playlistName != this.m_oldName) {
            for (uint i = 0; i < savedPlaylists.Length; i++) {
                if (savedPlaylists[i].Name == this.m_playlistName) {
                    nameExists = true;
                    break;
                }
            }

            if (nameExists) {
                Controls::FrameWarning(Icons::ExclamationTriangle + " A playlist with that name already exists!");
            }
        }

        if (tooLong) {
            Controls::FrameWarning(Icons::ExclamationTriangle + " Playlist name is too long! (Max. 50 characters)");
        }

        UI::AlignTextToFramePadding();
        UI::Text("Tags: ");

        UI::SameLine();

        UI::SetNextItemWidth(225);
        if (UI::BeginCombo("##Tags", tostring(this.m_oldList.Tags.Length) + " selected")) {
            if (UI::IsWindowAppearing()) {
                this.m_tagSearch = "";
            }

            UI::SetNextItemWidth(180);
            this.m_tagSearch = UI::InputText("##OldListSearch", this.m_tagSearch);

            UI::Separator();

            foreach (TMX::Tag@ tag : TMX::AllTags) {
                if (!tag.Name.ToLower().Contains(this.m_tagSearch.ToLower())) {
                    continue;
                }

                bool HasTag = this.m_oldList.HasTag(tag);

                if (UI::Checkbox("##" + tag.Name, HasTag)) {
                    if (!HasTag) {
                        this.m_oldList.AddTag(tag);
                    }
                } else if (HasTag) {
                    this.m_oldList.RemoveTag(tag);
                }

                UI::SameLine();
                tag.Render();
            }

            UI::EndCombo();
        }

        vec2 region = UI::GetContentRegionAvail();

        if (UI::BeginChild("MapsChild", vec2(0, region.y - (40 * UI::GetScale())))) {
            UI::PushStyleVar(UI::StyleVar::IndentSpacing, 5);
            UI::PushStyleColor(UI::Col::HeaderHovered, vec4(0.3f, 0.3f, 0.3f, 0.8f));

            if (UI::TreeNode("Maps (" + this.m_oldList.Length + ")###Maps", UI::TreeNodeFlags::FramePadding | UI::TreeNodeFlags::SpanAvailWidth | UI::TreeNodeFlags::DefaultOpen)) {
                UI::PushTableVars();

                if (UI::BeginTable("EditPlaylistMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                    UI::TableSetupScrollFreeze(0, 1);
                    UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                    UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthFixed, this.m_oldList.columnWidths.Author);
                    UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI::GetScale());
                    UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed);
                    UI::TableHeadersRow();

                    UI::ListClipper clipper(this.m_oldList.Length);
                    while (clipper.Step()) {
                        for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, this.m_oldList.Length); i++) {
                            UI::PushID("EditMap" + i);

                            UI::TableNextRow();
                            UI::TableNextColumn();

                            Map@ map = this.m_oldList[i];

                            UI::AlignTextToFramePadding();
                            UI::Text(map.Name);

                            if (S_MapThumbnail) {
                                if (map.ThumbnailUrl == "") {
                                    UI::SetItemTooltip("\\$f00" + Icons::Times + "\\$z No thumbnail available.");
                                } else {
                                    UI::ThumbnailTooltip(map.ThumbnailUrl);
                                }
                            }

                            UI::TableNextColumn();
                            UI::Text(map.Author);

                            UI::TableNextColumn();
                            UI::Text(UI::FormatMedal(map.AuthorScore, map.GameMode, Medals::Author));
                            UI::MedalsToolTip(map);

                            UI::TableNextColumn();
                            if (UI::RedButton(Icons::TrashO)) {
                                this.m_oldList.DeleteMap(map);
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

        UI::BeginDisabled(this.m_playlistName == "" || nameExists || tooLong || this.m_oldList.IsEmpty());

        UI::RightAlignButton(UI::MeasureButton(Icons::FloppyO + " Save").x);

        if (UI::GreenButton(Icons::FloppyO + " Save")) {
            this.m_oldList.Name = this.m_playlistName;
            Saves::EditPlaylist(this.m_oldName, this.m_oldList);

            this.Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Save current playlist");
    }
}
