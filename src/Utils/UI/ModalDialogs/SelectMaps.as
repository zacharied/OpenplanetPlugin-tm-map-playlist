class SelectMaps: ModalDialog {
    array<Map@>@ m_maps;
    array<Map@> m_selectedMaps;

    SelectMaps(Campaign@ campaign) {
        super(campaign.Name + "###SelectMaps");
        this.m_size = vec2(700, 500);

        @this.m_maps = campaign.MapList;
        campaign.LoadMapData();
        this.m_selectedMaps = this.m_maps;
    }

    SelectMaps(array<Map@> maps) {
        super("Maps###SelectMaps");
        this.m_size = vec2(700, 500);

        @this.m_maps = maps;
        this.m_selectedMaps = this.m_maps;
    }

    SelectMaps(MXMappackInfo@ mappack) {
        super(mappack.Name + " Mappack###SelectMaps");
        this.m_size = vec2(700, 500);

        @this.m_maps = mappack.Maps;
        this.m_selectedMaps = this.m_maps;
    }

    void Clear() {
        this.m_selectedMaps.RemoveRange(0, this.m_selectedMaps.Length);
    }

    void SelectAll() {
        this.m_selectedMaps = this.m_maps;
    }

    void SelectMap(Map@ map) {
        if (!IsSelected(map)) {
            this.m_selectedMaps.InsertLast(map);
        }
    }

    void UnselectMap(Map@ map) {
        if (IsSelected(map)) {
            this.m_selectedMaps.RemoveAt(this.m_selectedMaps.FindByRef(map));
        }
    }

    bool IsSelected(Map@ map) {
        return this.m_selectedMaps.FindByRef(map) > -1;
    }

    uint get_SelectedCount() {
        return this.m_selectedMaps.Length;
    }

    void AddToPlaylist() {
        foreach (Map@ map : this.m_maps) {
            if (IsSelected(map)) {
                playlist.AddMap(map);
            }
        }
    }

    void RenderDialog() override {
        vec2 region = UI::GetContentRegionAvail();
        float itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;

        if (UI::BeginChild("MapsChild", vec2(0, region.y - (40 * UI::GetScale())))) {
            UI::BeginDisabled(this.SelectedCount == this.m_maps.Length);

            if (UI::Button("Select all")) {
                this.SelectAll();
            }

            UI::EndDisabled();

            UI::SameLine();

            UI::BeginDisabled(this.SelectedCount == 0);

            if (UI::Button("Deselect all")) {
                this.Clear();
            }

            UI::EndDisabled();

            UI::PushTableVars();

            if (UI::BeginTable("CampaignMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);
                UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI::GetScale());
                UI::TableHeadersRow();

                UI::ListClipper clipper(this.m_maps.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        UI::PushID("CampaignMap" + i);

                        UI::TableNextRow();
                        UI::TableNextColumn();

                        Map@ map = this.m_maps[i];
                        bool selected = this.IsSelected(map);

                        if (UI::Checkbox("##Selected" + i, selected)) {
                            if (!selected) {
                                this.SelectMap(map);
                            }
                        } else if (selected) {
                            this.UnselectMap(map);
                        }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();

                        UI::BeginDisabled(!selected);

                        UI::Text(map.Name);

                        UI::TableNextColumn();
                        UI::Text(map.Author);

                        UI::TableNextColumn();
                        UI::Text(UI::FormatMedal(map.AuthorScore, map.GameMode, Medals::Author));
                        UI::MedalsToolTip(map);

                        UI::EndDisabled();

                        UI::PopID();
                    }
                }
                UI::EndTable();
            }

            UI::PopTableVars();
        }
        UI::EndChild();

        string buttonStr = "Add " + this.SelectedCount + Pluralize(" map", this.SelectedCount);

        region = UI::GetContentRegionAvail();
        vec2 pos = UI::GetCursorPos();
        vec2 dimensions = UI::MeasureButton(buttonStr);
        float newPos = Math::Max(region.x - dimensions.x - itemSpacing, 0.0);
        UI::SetCursorPosX(pos.x + newPos);

        UI::BeginDisabled(this.SelectedCount == 0);

        if (UI::GreenButton(buttonStr)) {
            this.AddToPlaylist();
            this.Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Add campaign maps to the playlist.");
    }
}
