namespace UI {
    void RenderMap(Map@ map, int i) {
        UI::TableNextRow();
        UI::TableNextColumn();

        if (playlist.currentMap !is null && playlist.currentMap == map) {
            // highlight current map
            UI::TableSetBgColor(UI::TableBgTarget::RowBg0, vec4(0.2, 0.55, 0.15, 0.2));
        }

        UI::AlignTextToFramePadding();
        UI::Text(tostring(i + 1));

        UI::TableNextColumn();
        UI::Text(S_ColoredNames ? map.GbxName : map.Name);

        UI::TableNextColumn();
        UI::Text(map.Author);

        UI::TableNextColumn();
        UI::Text(map.URL);

        UI::SetItemTooltip("Click to copy to clipboard");
        if (UI::IsItemClicked()) {
            IO::SetClipboard(map.URL);
            UI::ShowNotification(PLUGIN_NAME, Icons::Clipboard + " URL copied to clipboard");
        }

        UI::TableNextColumn();
        if (map.UID == "") UI::Text("-");
        else UI::Text(tostring(map.GameMode));

        UI::TableNextColumn();
        UI::Text(UI::FormatMedal(map.AuthorTime, map.GameMode, Medals::Author));
        UI::MedalsToolTip(map);

        UI::TableNextColumn();

        UI::BeginDisabled(TM::IsLoadingMap());

        if (UI::GreenButton(Icons::Play)) {
            playlist.PlayMap(map);
        }

        UI::EndDisabled();

        UI::SameLine();

        UI::BeginDisabled(i == 0);

        if (UI::Button(Icons::ArrowUp)) {
            playlist.ShiftMap(map);
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Move up");

        UI::SameLine();

        UI::BeginDisabled(i == int(playlist.Length - 1));

        if (UI::Button(Icons::ArrowDown)) {
            playlist.ShiftMap(map, true);
        }

        UI::EndDisabled();

        UI::SetItemTooltip("Move down");

        UI::SameLine();

        if (UI::RedButton(Icons::TrashO)) {
            playlist.DeleteMap(map);
        }

        UI::SetItemTooltip("Remove map");
    }

    void RenderPlaylist(Json::Value@ list, int i) {
        UI::TableNextRow();
        UI::TableNextColumn();

        UI::AlignTextToFramePadding();
        UI::Text(tostring(i + 1));

        UI::TableNextColumn();
        UI::Text(list["Name"]);

        UI::TableNextColumn();
        UI::Text(tostring(list["Maps"].Length));

        UI::TableNextColumn();
        UI::Text(Time::FormatString("%F %T", int(list["Timestamp"])));

        UI::TableNextColumn();

        if (UI::Button(Icons::Upload)) {
            // TODO probably want to set the current tab
            playlist.Load(list);
        }
        UI::SetItemTooltip("Load");

        UI::SameLine();

        if (UI::RedButton(Icons::TrashO)) {
            Renderables::Add(DeletePlaylist(list["Name"]));
        }
        UI::SetItemTooltip("Delete");
    }

    void PushTableVars() {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.1f, 0.1f, 0.1f, .7));
        UI::PushStyleColor(UI::Col::TableRowBg, vec4(0.13f, 0.13f, 0.13f, .7));
        UI::PushStyleColor(UI::Col::TableBorderLight, vec4(.25, .25, .25, 1));
        UI::PushStyleVar(UI::StyleVar::CellPadding, UI::GetStyleVarVec2(UI::StyleVar::CellPadding) + vec2(6, 1));
    }

    void PopTableVars() {
        UI::PopStyleVar();
        UI::PopStyleColor(3);
    }
}
