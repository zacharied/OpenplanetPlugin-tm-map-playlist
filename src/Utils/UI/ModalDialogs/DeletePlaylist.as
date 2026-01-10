class DeletePlaylist: ModalDialog {
    MapPlaylist@ m_playlist;

    DeletePlaylist(MapPlaylist@ list) {
        @this.m_playlist = list;
        super(Icons::TrashO + " Delete Playlist###DeletePlaylist");
        this.m_size = vec2(400, 160);
    }

    void RenderDialog() override {
        UI::AlignTextToFramePadding();

        UI::Text("Are you sure you want to delete this playlist?");

        UI::Text("Name: " + m_playlist.Name);
        UI::Text("Map count: " + m_playlist.Length);

        float width = UI::MeasureButton(Icons::TrashO + " Delete").x;
        float width2 = UI::MeasureButton("Cancel").x;
        UI::RightAlignButtons(width + width2, 2);

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
