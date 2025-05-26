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
        UI::Text(UI::FormatMedal(map.AuthorTime, map.GameMode, Medals::Author));
        UI::MedalsToolTip(map);

        UI::TableNextColumn();

        if (UI::GreenButton(Icons::Play)) {
            playlist.PlayMap(map);
        }

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
}