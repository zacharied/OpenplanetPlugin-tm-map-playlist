class DeletePlaylist: ModalDialog {
    string m_playlistName;

    DeletePlaylist(const string &in name) {
        m_playlistName = name;
        super("Delete Playlist###DeletePlaylist");
        m_size = vec2(400, 150);
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();

        UI::TextWrapped("Are you sure you want to delete the playlist \"" + m_playlistName + "\"?");

        vec2 region = UI::GetContentRegionAvail();
        UI::VPadding(region.y - 40 * UI_SCALE);

        vec2 pos = UI::GetCursorPos();
        UI::SetCursorPos(vec2(region.x - 150 * UI_SCALE, pos.y));

        if (UI::RedButton(Icons::TrashO + " Delete")) {
            Saves::DeletePlaylist(m_playlistName);
            Close();
        }

        UI::SameLine();

        if (UI::Button("Cancel")) {
            Close();
        }
    }
}
