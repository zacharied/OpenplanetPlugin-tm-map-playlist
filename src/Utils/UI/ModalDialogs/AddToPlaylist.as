class AddToPlaylist: ModalDialog {
    CGameCtnChallenge@ m_currentChallenge;
    MapPlaylist@ m_selectedPlaylist;

    bool[] m_playlistSelection;
    bool[] m_alreadyPresentPlaylists;
    
    AddToPlaylistSource m_source = AddToPlaylistSource::NadeoServices;
    
    AddToPlaylist() {
        super("Add to Playlist##AddToPlaylist");

        @m_currentChallenge = GetApp().RootMap;
        if (m_currentChallenge is null || m_currentChallenge.MapInfo is null) {
            return;    
        }

        this.m_size = vec2(700, 500);

        m_alreadyPresentPlaylists = array<bool>(savedPlaylists.Length);
        for (uint i = 0; i < savedPlaylists.Length; i++) {
            foreach (auto map : savedPlaylists[i].Maps) {
                if (map.Uid == m_currentChallenge.MapInfo.MapUid) {
                    m_alreadyPresentPlaylists[i] = true;
                    break;
                }
            }
        }
    }

    void RenderDialog() override {
        if (m_currentChallenge is null || m_currentChallenge.MapInfo is null) {
            Close();
            return;
        }
        
        UI::AlignTextToFramePadding();
        
        UI::Text(Text::OpenplanetFormatCodes(CleanGbxText(m_currentChallenge.MapName)) + " will be added to the selected playlist.");

        vec2 region = UI::GetContentRegionAvail();

        if (UI::BeginChild("PlaylistsChild", vec2(0, region.y - (40 * UI::GetScale())))) {
            UI::PushStyleVar(UI::StyleVar::IndentSpacing, 5);
            UI::PushStyleColor(UI::Col::HeaderHovered, vec4(0.3f, 0.3f, 0.3f, 0.8f));

            UI::PushTableVars();
            if (UI::BeginTable("PlaylistsTable", 2, UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX | UI::TableFlags::BordersInnerH)) {
        
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Map Count", UI::TableColumnFlags::WidthFixed, 120 * UI::GetScale());
                
                if (m_playlistSelection is null || m_playlistSelection.Length != savedPlaylists.Length) {
                    m_playlistSelection = array<bool>(savedPlaylists.Length);
                }

                UI::TableHeadersRow();

                for (uint i = 0; i < savedPlaylists.Length; i++) {
                    const MapPlaylist@ list = savedPlaylists[i];
                    
                    UI::TableNextRow();
                    UI::TableNextColumn();

                    UI::BeginDisabled(m_alreadyPresentPlaylists[i]);
                    if (UI::RadioButton(list.Name, m_playlistSelection[i])) {
                        for (uint j = 0; j < m_playlistSelection.Length; j++) {
                            m_playlistSelection[j] = false;
                        }
                        m_playlistSelection[i] = true; 
                    }
                    
                    if (m_alreadyPresentPlaylists[i]) {
                        UI::SameLine(0, 4 * UI::GetScale());
                        UI::Text(Icons::ExclamationCircle);
                        UI::SetItemTooltip("The current map is already present in this playlist.");
                    }
                    UI::EndDisabled();
                    
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
        
        int selectedIndex = m_playlistSelection.Find(true); 
        @m_selectedPlaylist = selectedIndex < 0 ? null : savedPlaylists[selectedIndex];
        
        UI::SetNextItemWidth(150);
        if (UI::BeginCombo("Source##AddToPlaylistSource", tostring(m_source))) {
            for (int i = 0; i < AddToPlaylistSource::Last; i++) {
                if (UI::Selectable(tostring(AddToPlaylistSource(i)), m_source == AddToPlaylistSource(i))) {
                    m_source = AddToPlaylistSource(i);
                }
            }
            UI::EndCombo();
        }

        UI::SameLine();

        UI::BeginDisabled(m_selectedPlaylist is null);

        UI::RightAlignButton(UI::MeasureButton(Icons::Plus + " Add").x);
        if (UI::GreenButton(Icons::Plus + " Add")) {
            startnew(CoroutineFunc(this.AddMapToPlaylist));
            Close();
        }
        UI::SetItemTooltip("Add current map to the selected playlist");

        UI::EndDisabled();
    }
    
    void AddMapToPlaylist() {
        Map@ map;

        switch (m_source) {
            case AddToPlaylistSource::NadeoServices:
                @map = TM::GetMapFromUid(m_currentChallenge.MapInfo.MapUid);
                break;
            case AddToPlaylistSource::TMX:
                @map = TMX::GetMapFromUid(m_currentChallenge.MapInfo.MapUid);
                break; 
            case AddToPlaylistSource::File:
                @map = Map(m_currentChallenge, m_currentChallenge.MapInfo.FileName);
                break;
            default:
                return;
        }

        if (map is null)
            return;

        m_selectedPlaylist.AddMap(map);
        UI::ShowNotification("Map Added", Text::OpenplanetFormatCodes(CleanGbxText(map.Name)) + " has been added to playlist " + m_selectedPlaylist.Name + ".");
    }
}

enum AddToPlaylistSource {
    NadeoServices,
    TMX,
    File,
    Last
}
