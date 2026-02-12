class AddToPlaylist: ModalDialog {
    CGameCtnChallenge@ m_currentChallenge;

    bool[] m_checkedPlaylists;
    bool[] m_alreadyPresentPlaylists;
    
    AddUidToPlaylistSource m_source = AddUidToPlaylistSource::TMX;
    
    AddToPlaylist() {
        super("Add to Playlist##AddToPlaylist");

        auto currentMap = cast<CTrackMania>(GetApp()).RootMap;
        if (TM::InEditor() || currentMap is null || currentMap.MapInfo is null) {
            Close();
            return;
        }
        
        this.Init(currentMap);
    }
    
    AddToPlaylist(CGameCtnChallenge@ &in challenge) {
        super("Add to Playlist##AddToPlaylist");
        
        if (challenge is null) {
            Close();
            return;
        }
        
        this.Init(challenge);
    }
    
    private void Init(CGameCtnChallenge@ &in challenge) {
        @m_currentChallenge = challenge;

        m_checkedPlaylists = array<bool>(savedPlaylists.Length);

        m_alreadyPresentPlaylists = array<bool>(savedPlaylists.Length);
        for (uint i = 0; i < savedPlaylists.Length; i++) {
            foreach (auto map : savedPlaylists[i].Maps) {
                if (map.Uid == m_currentChallenge.MapInfo.MapUid) {
                    m_alreadyPresentPlaylists[i] = true;
                    break;
                }
            }
        }

        m_size = vec2(700, 500);
    }

    void RenderDialog() override {
        if (m_currentChallenge is null || m_currentChallenge.MapInfo is null) {
            Close();
            return;
        }
        
        UI::AlignTextToFramePadding();
        
        UI::Text(Text::OpenplanetFormatCodes(CleanGbxText(m_currentChallenge.MapName)));
        UI::SameLine(0, 0);
        UI::Text(" will be added to the selected playlists.");

        vec2 region = UI::GetContentRegionAvail();

        if (UI::BeginChild("PlaylistsChild", vec2(0, region.y - (40 * UI::GetScale())))) {
            UI::PushStyleVar(UI::StyleVar::IndentSpacing, 5);
            UI::PushStyleColor(UI::Col::HeaderHovered, vec4(0.3f, 0.3f, 0.3f, 0.8f));

            UI::PushTableVars();
            if (UI::BeginTable("PlaylistsTable", 3, UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerH | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Tags", UI::TableColumnFlags::WidthFixed, 180 * UI::GetScale());
                UI::TableSetupColumn("Map Count", UI::TableColumnFlags::WidthFixed, 80 * UI::GetScale());
                
                UI::TableHeadersRow();

                for (uint i = 0; i < savedPlaylists.Length; i++) {
                    const MapPlaylist@ list = savedPlaylists[i];
                    
                    UI::TableNextRow();

                    UI::TableNextColumn();
                    

                    UI::BeginDisabled(m_alreadyPresentPlaylists[i]);
                    m_checkedPlaylists[i] = UI::Checkbox(list.Name, m_checkedPlaylists[i]);
                    
                    if (m_alreadyPresentPlaylists[i]) {
                        UI::SameLine(0, 4 * UI::GetScale());
                        UI::Text(Icons::ExclamationCircle);
                        UI::SetItemTooltip("The current map is already present in this playlist.");
                    }
                    UI::EndDisabled();
                
                    UI::TableNextColumn();

                    foreach (auto tag : list.Tags) {
                        tag.Render(); 
                        UI::SameLine();
                    }
                    
                    UI::TableNextColumn();

                    UI::Text(tostring(list.Maps.Length));
                }

                UI::EndTable();
            }
            
            UI::PopTableVars();
            UI::PopStyleColor();
            UI::PopStyleVar();
        }
        UI::EndChild();
        
        UI::SetNextItemWidth(150);
        if (UI::BeginCombo("Source##AddToPlaylistSource", GetSourceLabelText(m_source))) {
            for (int i = 0; i < AddUidToPlaylistSource::Last; i++) {
                if (UI::Selectable(GetSourceLabelText(AddUidToPlaylistSource(i)) + "##" + tostring(AddUidToPlaylistSource(i)), m_source == AddUidToPlaylistSource(i))) {
                    m_source = AddUidToPlaylistSource(i);
                }
            }
            UI::EndCombo();
        }

        uint checkedPlaylistCount = 0;
        foreach (bool checked : m_checkedPlaylists) {
            if (checked) {
                checkedPlaylistCount++;
            }
        }

        auto selectedCountText = tostring(checkedPlaylistCount) + " playlist(s) selected";
        auto addButtonText = Icons::Plus + " Add";
        auto nextX = UI::GetContentRegionAvail().x - UI::MeasureButton(addButtonText).x - UI::MeasureString(selectedCountText).x;

        UI::SameLine(nextX, 0);

        UI::Text(selectedCountText);

        UI::SameLine();

        UI::BeginDisabled(checkedPlaylistCount == 0);
        
        if (UI::GreenButton(addButtonText)) {
            startnew(CoroutineFunc(this.AddMapToSelectedPlaylists));
            Close();
        }
        UI::SetItemTooltip("Add current map to the selected playlist");

        UI::EndDisabled();
    }
    
    private void AddMapToSelectedPlaylists() {
        Map@ map;

        switch (m_source) {
            case AddUidToPlaylistSource::TMX:
                @map = TMX::GetMapFromUid(m_currentChallenge.MapInfo.MapUid);
                break; 
            case AddUidToPlaylistSource::NadeoServices:
                @map = TM::GetMapFromUid(m_currentChallenge.MapInfo.MapUid);
                break;
            case AddUidToPlaylistSource::File:
                @map = Map(m_currentChallenge, m_currentChallenge.MapInfo.FileName);
                break;
        }

        if (map is null)
            return; 
        
        MwFastBuffer<MapPlaylist@> selectedPlaylists;
        for (uint i = 0; i < m_checkedPlaylists.Length; i++) {
            if (m_checkedPlaylists[i]) {
                selectedPlaylists.Add(savedPlaylists[i]);
            }
        }

        for (uint i = 0; i < selectedPlaylists.Length; i++) {
            auto playlist = selectedPlaylists[i];
            UI::ShowNotification("Map Added", Text::OpenplanetFormatCodes(CleanGbxText(map.Name)) + " has been added to playlist \"" + playlist.Name + "\".");
            playlist.AddMap(map);
        }
    }
    
    private const string GetSourceLabelText(AddUidToPlaylistSource source) {
        switch (source) {
            case AddUidToPlaylistSource::TMX:
                return "TMX";
            case AddUidToPlaylistSource::NadeoServices:
                return "Nadeo services"; 
            case AddUidToPlaylistSource::File:
                return "Local file";
            default:
                return "";
        }
    }
}

enum AddUidToPlaylistSource {
    TMX,
    NadeoServices,
    File,
    Last
}
