namespace UI
{
    // Alignment

    void CenterAlign() {
        vec2 region = UI::GetWindowSize();
        vec2 position = UI::GetCursorPos();
        UI::SetCursorPos(vec2(region.x / 2, position.y));
    }

    void SetItemText(const string &in text, int width = 300) {
        UI::AlignTextToFramePadding();
        UI::Text(text);
        UI::SameLine();
        UI::SetNextItemWidth(width - Draw::MeasureString(text).x);
    }

    void SetCenteredItemText(const string &in text, int width = 300) {
        UI::SameLine();
        UI::CenterAlign();
        SetItemText(text, width);
    }

    // Padding

    void VPadding() {
        UI::Dummy(vec2(0, 10));
    }

    void VPadding(int y) {
        UI::Dummy(vec2(0, y));
    }

    void VPadding(float y) {
        UI::Dummy(vec2(0., y));
    }

    void PaddedSeparator(const string &in text) {
        UI::VPadding(5);
        UI::SeparatorText(text);
        UI::VPadding(5);
    }

    // Button

    bool ResetButton() {
        UI::SameLine();
        UI::Text(Icons::Times);
        if (UI::IsItemHovered()) UI::SetMouseCursor(UI::MouseCursor::Hand);
        UI::SetItemTooltip("Reset field");

        return UI::IsItemClicked();
    }

    vec2 MeasureButton(const string &in label) {
        vec2 text = Draw::MeasureString(label);
        vec2 padding = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);

        return text + padding;
    }

    void SettingDescription(const string &in text) {
        UI::SameLine();
        UI::TextDisabled(Icons::QuestionCircle);
        UI::SetItemTooltip(text);
    }
}
