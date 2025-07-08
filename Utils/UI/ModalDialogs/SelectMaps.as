class SelectMaps: ModalDialog {
    array<Map@>@ m_maps;
    uint m_selectedCount;

    SelectMaps(Campaign@ campaign) {
        super(campaign.Name + "###SelectMaps");
        m_size = vec2(700, 500);
        @m_maps = campaign.MapList;
        campaign.LoadMapData();
        m_selectedCount = m_maps.Length;
    }

    SelectMaps(array<Map@> maps) {
        super("Maps" + "###SelectMaps");
        m_size = vec2(700, 500);
        @m_maps = maps;
        m_selectedCount = m_maps.Length;
    }

    SelectMaps(MXMappackInfo@ mappack) {
        super(mappack.Name + " Mappack###SelectMaps");
        m_size = vec2(700, 500);
        @m_maps = mappack.Maps;
        m_selectedCount = m_maps.Length;
    }

    void Clear() {
        for (uint i = 0; i < m_maps.Length; i++) {
            Map@ map = m_maps[i];
            map.Selected = false;
        }
        m_selectedCount = 0;
    }

    void SelectAll() {
        for (uint i = 0; i < m_maps.Length; i++) {
            Map@ map = m_maps[i];
            map.Selected = true;
        }
        m_selectedCount = m_maps.Length;
    }

    void AddToPlaylist() {
        for (uint i = 0; i < m_maps.Length; i++) {
            Map@ map = m_maps[i];

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
                SelectAll();
            }

            UI::SameLine();

            if (UI::Button("Deselect all")) {
                Clear();
            }

            UI::PushTableVars();

            if (UI::BeginTable("CampaignMaps", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);
                UI::TableSetupColumn("", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                UI::TableHeadersRow();

                UI::ListClipper clipper(m_maps.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                        UI::PushID("CampaignMap" + i);

                        UI::TableNextRow();
                        UI::TableNextColumn();

                        Map@ map = m_maps[i];

                        if (UI::Checkbox("##Selected" + i, map.Selected)) {
                            if (!map.Selected) {
                                map.Selected = true;
                                m_selectedCount++;
                            }
                        } else if (map.Selected) {
                            map.Selected = false;
                            m_selectedCount--;
                        }

                        UI::TableNextColumn();
                        UI::AlignTextToFramePadding();

                        UI::BeginDisabled(!map.Selected);

                        UI::Text(map.Name);

                        UI::TableNextColumn();
                        UI::Text(map.Author);

                        UI::TableNextColumn();
                        UI::Text(UI::FormatMedal(map.AuthorTime, map.GameMode, Medals::Author));
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

        string buttonStr = "Add " + m_selectedCount + Pluralize(" map", m_selectedCount);

        region = UI::GetContentRegionAvail();
        vec2 pos = UI::GetCursorPos();
        vec2 dimensions = UI::MeasureButton(buttonStr);
        float newPos = Math::Max(region.x - dimensions.x - itemSpacing, 0.0);
        UI::SetCursorPosX(pos.x + newPos);

        UI::BeginDisabled(m_selectedCount == 0);

        if (UI::GreenButton(buttonStr)) {
            AddToPlaylist();
            Close();
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Add campaign maps to the playlist.");
    }
}
