class SelectMaps: ModalDialog {
    array<Map@>@ m_maps;
    uint m_selectedCount;

    SelectMaps(Campaign@ campaign) {
        super(campaign.Name + "###SelectMaps");
        this.m_size = vec2(700, 500);

        @this.m_maps = campaign.MapList;
        campaign.LoadMapData();
        this.m_selectedCount = campaign.Length;
    }

    SelectMaps(array<Map@> maps) {
        super("Maps" + "###SelectMaps");
        this.m_size = vec2(700, 500);

        @this.m_maps = maps;
        this.m_selectedCount = this.m_maps.Length;
    }

    SelectMaps(MXMappackInfo@ mappack) {
        super(mappack.Name + " Mappack###SelectMaps");
        this.m_size = vec2(700, 500);

        @this.m_maps = mappack.Maps;
        this.m_selectedCount = this.m_maps.Length;
    }

    void Clear() {
        for (uint i = 0; i < this.m_maps.Length; i++) {
            Map@ map = this.m_maps[i];
            map.Selected = false;
        }
        this.m_selectedCount = 0;
    }

    void SelectAll() {
        for (uint i = 0; i < this.m_maps.Length; i++) {
            Map@ map = this.m_maps[i];
            map.Selected = true;
        }
        m_selectedCount = this.m_maps.Length;
    }

    void AddToPlaylist() {
        for (uint i = 0; i < this.m_maps.Length; i++) {
            Map@ map = this.m_maps[i];

            if (map.Selected) {
                playlist.AddMap(map);
            }
        }
    }

    void RenderDialog() override {
        vec2 region = UI::GetContentRegionAvail();
        float itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;

        if (UI::BeginChild("MapsChild", vec2(0, region.y - (40 * UI_SCALE)))) {
            if (UI::Button("Select all")) {
                this.SelectAll();
            }

            UI::SameLine();

            if (UI::Button("Deselect all")) {
                this.Clear();
            }

            UI::PushTableVars();

            if (UI::BeginTable("CampaignMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);
                UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                UI::TableHeadersRow();

                UI::ListClipper clipper(this.m_maps.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        UI::PushID("CampaignMap" + i);

                        UI::TableNextRow();
                        UI::TableNextColumn();

                        Map@ map = this.m_maps[i];

                        if (UI::Checkbox("##Selected" + i, map.Selected)) {
                            if (!map.Selected) {
                                map.Selected = true;
                                this.m_selectedCount++;
                            }
                        } else if (map.Selected) {
                            map.Selected = false;
                            this.m_selectedCount--;
                        }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();

                        UI::BeginDisabled(!map.Selected);

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

        string buttonStr = "Add " + this.m_selectedCount + Pluralize(" map", this.m_selectedCount);

        region = UI::GetContentRegionAvail();
        vec2 pos = UI::GetCursorPos();
        vec2 dimensions = UI::MeasureButton(buttonStr);
        float newPos = Math::Max(region.x - dimensions.x - itemSpacing, 0.0);
        UI::SetCursorPosX(pos.x + newPos);

        UI::BeginDisabled(this.m_selectedCount == 0);

        if (UI::GreenButton(buttonStr)) {
            AddToPlaylist();
            this.Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Add campaign maps to the playlist.");
    }
}
