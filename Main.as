void Main() {
    if (!HAS_PERMISSIONS) {
        _Logging::Error("You don't have enough permissions to use this plugin!", true);

        Meta::Plugin@ self = Meta::ExecutingPlugin();
        Meta::UnloadPlugin(self);
    }

    Saves::LoadPlaylists();
}

Source m_source = Source::TMX_Map_ID;
string m_field = "";

[Setting hidden]
bool showWindow = true;

void RenderMenu() {
    if (HAS_PERMISSIONS && UI::MenuItem(FULL_NAME, "", showWindow)) {
        showWindow = !showWindow;
    }
}

MapPlaylist@ playlist = MapPlaylist();
string playlistName;

void Render() {
    if (!HAS_PERMISSIONS || !showWindow || (S_HideWithOP && !UI::IsOverlayShown()) || (S_HideWithGameUI && !UI::IsGameUIVisible())) {
        return;
    }

    UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
    UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
    UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
    UI::PushStyleVar(UI::StyleVar::CellPadding, UI::GetStyleVarVec2(UI::StyleVar::CellPadding) + vec2(4, 1));

    UI::SetNextWindowSize(600, 400, UI::Cond::FirstUseEver);

    if (UI::Begin(FULL_NAME, showWindow, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking)) {
        UI::BeginTabBar("WindowTabs", UI::TabBarFlags::FittingPolicyResizeDown);

        if(UI::BeginTabItem("Maps")) {
            UI::SetNextItemWidth(160);
            if (UI::BeginCombo("##AddSource", tostring(m_source).Replace("_", " "))) {
                for (uint i = 0; i <= Source::Folder; i++) {
                    UI::PushID("SourceBtn" + i);

                    if (UI::Selectable(tostring(Source(i)).Replace("_", " "), m_source == Source(i))) {
                        m_source = Source(i);
                        m_field = "";
                    }

                    UI::PopID();
                }

                UI::EndCombo();
            }

            UI::SameLine();

            RenderField();

            UI::SameLine();

            UI::BeginDisabled(playlist.IsEmpty());

            if (UI::RedButton(Icons::TrashO + " Clear")) {
                playlist.Clear();
            }

            UI::SameLine();

            if (UI::Button(Icons::Random)) {
                playlist.Randomize();
            }

            UI::SetItemTooltip("Shuffle playlist");

            UI::EndDisabled();

            UI::SameLine();

            S_Editor = UI::Checkbox("Load in Editor", S_Editor);

            UI::PushTableVars();
            if (UI::BeginTable("Maps", 6, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Author", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("URL", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Medals", UI::TableColumnFlags::WidthFixed, 120 * UI_SCALE);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthFixed);
                UI::TableHeadersRow();

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

        if(UI::BeginTabItem("Playlists")) {
            array<string> keys = savedPlaylists.GetKeys();

            UI::BeginDisabled(playlist.Length == 0);

            if (UI::GreenButton(Icons::Plus + " New")) {
                Renderables::Add(AddPlaylist());
            }

            UI::SetItemTooltip("Save current playlist");

            UI::EndDisabled();

            UI::PushTableVars();
            if (UI::BeginTable("Playlists", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::BordersInnerV | UI::TableFlags::PadOuterX)) {
                UI::TableSetupScrollFreeze(0, 1);

                UI::TableSetupColumn("Nº", UI::TableColumnFlags::WidthFixed, 30);
                UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Map Count", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Created at", UI::TableColumnFlags::WidthStretch);
                UI::TableSetupColumn("Buttons", UI::TableColumnFlags::WidthStretch);
                UI::TableHeadersRow();

                UI::ListClipper clipper(keys.Length);
                while (clipper.Step()) {
                    for (int i = clipper.DisplayStart; i < Math::Min(clipper.DisplayEnd, keys.Length); i++) {
                        UI::PushID("Playlist"+i);
                        Json::Value@ list = savedPlaylists[keys[i]];
                        UI::RenderPlaylist(list, i);
                        UI::PopID();
                    }
                }
                UI::EndTable();
            }
            UI::PopTableVars();
            UI::EndTabItem();
        }

        UI::EndTabBar();

        
    }

    UI::End();
    UI::PopStyleVar(5);

    Renderables::Render();
}

void RenderField() {
    bool pressedEnter = false;

    int inputFlags = UI::InputTextFlags::EnterReturnsTrue;
    UI::InputTextCallback@ callback;

    if (m_source == Source::TMX_Map_ID || m_source == Source::TMX_Mappack_ID) {
        inputFlags |= UI::InputTextFlags::CharsDecimal | UI::InputTextFlags::CallbackCharFilter | UI::InputTextFlags::CallbackAlways;
        @callback = UI::InputTextCallback(UI::IdCallback);
    }

    UI::SetNextItemWidth(200);
    m_field = UI::InputText("##SourceInput", m_field, pressedEnter, inputFlags, callback);

    UI::SameLine();

    UI::BeginDisabled(m_field.Length == 0);

    if ((UI::Button("Add map##AddMap") || pressedEnter) && m_field.Length > 0) {
        switch (m_source) {
            case Source::TMX_Map_ID:
                startnew(CoroutineFuncUserdataString(playlist.AddFromTMXId), m_field);
                break;
            case Source::TMX_Mappack_ID:
                startnew(CoroutineFuncUserdataString(playlist.AddMappack), m_field);
                break;
            case Source::UUID:
                startnew(CoroutineFuncUserdataString(playlist.AddFromUuid), m_field);
                break;
            case Source::File:
                startnew(CoroutineFuncUserdataString(playlist.AddFromFile), m_field.Replace("/", "\\"));
                break;
            case Source::Folder:
                startnew(CoroutineFuncUserdataString(playlist.AddFolder), m_field.Replace("/", "\\"));
                break;
            case Source::Map_URL:
            default:
                startnew(CoroutineFuncUserdataString(playlist.AddFromUrl), m_field);
                break;
        }

        m_field = "";
    }

    UI::EndDisabled();
}

bool held = false;

void OnKeyPress(bool down, VirtualKey key) {
    if (!HAS_PERMISSIONS || playlist.IsEmpty() || TM::IsLoadingMap()) return;

    if (!held && key == S_SwitchKey) {
        playlist.NextMap();
    }

    held = down;
}
