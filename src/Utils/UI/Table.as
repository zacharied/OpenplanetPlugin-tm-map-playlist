namespace UI {
    void RenderMap(Map@ map, int i) {
        UI::TableNextRow();
        UI::TableNextColumn();

        if (TM::InCurrentMap() && playlist.currentMap == map) {
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
        UI::Text(map.Url);

        UI::SetItemTooltip("Click to copy to clipboard");
        if (UI::IsItemClicked()) {
            IO::SetClipboard(map.Url);
            UI::ShowNotification(PLUGIN_NAME, Icons::Clipboard + " URL copied to clipboard");
        }

        UI::TableNextColumn();
        UI::Text(map.Uid);

        UI::SetItemTooltip("Click to copy to clipboard");
        if (UI::IsItemClicked()) {
            IO::SetClipboard(map.Uid);
            UI::ShowNotification(PLUGIN_NAME, Icons::Clipboard + " Uid copied to clipboard");
        }

        UI::TableNextColumn();
        if (map.Uid == "") UI::Text("-");
        else UI::Text(tostring(map.GameMode));

        UI::TableNextColumn();
        for (uint t = 0; t < map.Tags.Length; t++) {
            map.Tags[t].Render();
            UI::SameLine();
        }

        UI::TableNextColumn();
        if (S_MainMedal == Medals::Warrior && !map.HasWarrior) {
            UI::Text(UI::FormatMedal(map.AuthorScore, map.GameMode, Medals::Author));
        } else {
            int medal = map.GetMedal(S_MainMedal);
            UI::Text(UI::FormatMedal(medal, map.GameMode, S_MainMedal));
        }
        UI::MedalsToolTip(map);

        UI::TableNextColumn();
        string icon = UI::GetTimeIcon(map, map.Pb);
        string time = UI::FormatTime(map.Pb, map.GameMode);
        UI::Text(icon + time);

        UI::TableNextColumn();
        if (map.HasPb && !map.IsPbSecret) {
            int medal = map.GetMedal(S_MainMedal);
            UI::Text(UI::FormatDelta(medal, map.Pb, map.GameMode));
        }

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

    void RenderPlaylist(MapPlaylist@ list, int i) {
        UI::TableNextRow();
        UI::TableNextColumn();

        UI::AlignTextToFramePadding();
        UI::Text(tostring(i + 1));

        UI::TableNextColumn();
        UI::Text(list.Name);

        UI::TableNextColumn();
        UI::Text(tostring(list.Length));

        UI::TableNextColumn();
        UI::Text(Time::FormatString("%F %T", list.CreatedAt));

        UI::TableNextColumn();

        UI::BeginDisabled(playlist.IsEmpty());

        if (UI::Button(Icons::FloppyO)) {
            Saves::EditPlaylist(list.Name, playlist);
        }
        UI::SetItemTooltip("Save current playlist as \""+ list.Name +"\".");

        UI::EndDisabled();

        UI::SameLine();

        if (UI::Button(Icons::Upload)) {
            // TODO probably want to set the current tab
            playlist = list;
            UI::ShowNotification(PLUGIN_NAME, "Loaded playlist \"" + list.Name + "\"!");
        }
        UI::SetItemTooltip("Load");

        UI::SameLine();

        if (UI::Button(Icons::Pencil)) {
            Renderables::Add(EditPlaylist(list));
        }
        UI::SetItemTooltip("Edit");

        UI::SameLine();

        if (UI::RedButton(Icons::TrashO)) {
            Renderables::Add(DeletePlaylist(list));
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
