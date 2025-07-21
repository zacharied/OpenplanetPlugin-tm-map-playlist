class ModalDialog : IRenderable {
    string m_id;
    bool m_firstRender = false;
    bool m_visible = true;

    vec2 m_size = vec2(100, 100);
    int m_flags = UI::WindowFlags::NoSavedSettings | UI::WindowFlags::NoResize | UI::WindowFlags::NoMove;

    ModalDialog(const string &in id) {
        this.m_id = id;
    }

    void Render() {
        if (!this.m_firstRender) {
            UI::OpenPopup(this.m_id);
        }

        UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
        UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
        UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
        UI::SetNextWindowSize(int(this.m_size.x), int(this.m_size.y));

        bool isOpen = false;

        if (CanClose()) {
            isOpen = UI::BeginPopupModal(this.m_id, this.m_visible, this.m_flags);
        } else {
            isOpen = UI::BeginPopupModal(this.m_id, this.m_flags);
        }

        if (isOpen) {
            RenderDialog();
            UI::EndPopup();
        }

        UI::PopStyleVar(4);
    }

    bool CanClose() {
        return true;
    }

    bool ShouldDisappear() {
        return !this.m_visible;
    }

    void Close() {
        this.m_visible = false;
        UI::CloseCurrentPopup();
    }

    void RenderDialog() { }
}
