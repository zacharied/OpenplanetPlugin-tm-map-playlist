namespace UI {
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

    void RightAlignButton(float buttonWidth, int buttonCount = 1) {
        vec2 region = UI::GetContentRegionAvail();
        vec2 pos = UI::GetCursorPos();
        float itemSpacing = UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x;
        int spacingCount = buttonCount - 1;
        float newPos = Math::Max(region.x - buttonWidth - (itemSpacing * spacingCount), 0.0);
        UI::SetCursorPosX(pos.x + newPos);
    }

    void RightAlignButtons(float buttonsWidth, int buttonCount) {
        RightAlignButton(buttonsWidth, buttonCount);
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

        return text + padding * 2;
    }

    void SettingDescription(const string &in text) {
        UI::SameLine();
        UI::TextDisabled(Icons::QuestionCircle);
        if (UI::BeginItemTooltip()) {
            UI::PushTextWrapPos(500);
            UI::TextWrapped(text);
            UI::PopTextWrapPos();

            UI::EndTooltip();
        }
    }

    // Other

    bool IsMouseBetween(vec2 min, vec2 max) {
        vec2 mousePos = UI::GetMousePos();

        return mousePos.x >= min.x
            && mousePos.x <= max.x
            && mousePos.y >= min.y
            && mousePos.y <= max.y;        
    }

    // TODO this is very hacky
    vec2 GetCurrentCellSize() {
        vec2 padding = UI::GetStyleVarVec2(UI::StyleVar::CellPadding);
        float rowWidth = UI::GetContentRegionAvail().x;
        float rowHeight = MeasureButton("Placeholder").y + padding.y * 2;

        return vec2(rowWidth, rowHeight);
    }
}
