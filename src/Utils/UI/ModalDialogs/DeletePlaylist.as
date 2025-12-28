class DeletePlaylist: ModalDialog {
    MapPlaylist@ m_playlist;

    DeletePlaylist(MapPlaylist@ list) {
        @this.m_playlist = list;
        super(Icons::TrashO + " Delete Playlist###DeletePlaylist");
        this.m_size = vec2(400, 150);
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();

        UI::TextWrapped("Are you sure you want to delete the playlist \"" + this.m_playlist.Name + "\"?");

        vec2 region = UI::GetContentRegionAvail();
        UI::VPadding(region.y - 40 * UI::GetScale());

        float width = UI::MeasureButton(Icons::TrashO + " Delete").x;
        float width2 = UI::MeasureButton("Cancel").x;
        UI::BottomRightButtons(width + width2, 2);

        if (UI::RedButton(Icons::TrashO + " Delete")) {
            Saves::DeletePlaylist(this.m_playlist.Name);
            this.Close();
        }

        UI::SameLine();

        if (UI::Button("Cancel")) {
            this.Close();
        }
    }
}
