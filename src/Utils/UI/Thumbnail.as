namespace UI {
    void ThumbnailTooltip(const string &in url, float resize = 0.25) {
        if (UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled | UI::HoveredFlags::DelayShort | UI::HoveredFlags::NoSharedDelay)) {
            CachedImage@ img = Images::CachedFromURL(url);

            if (UI::BeginItemTooltip()) {
                float width = Display::GetWidth() * resize;

                if (img.m_texture !is null) {
                    vec2 thumbSize = img.m_texture.GetSize();
                    UI::Image(img.m_texture, vec2(
                        width,
                        thumbSize.y / (thumbSize.x / width)
                    ));

                    UI::EndTooltip();
                    return;
                }

                if (!img.m_error) {
                    UI::Text(Icons::AnimatedHourglass + " Loading Thumbnail...");
                } else if (img.m_notFound) {
                    UI::Text("\\$fc0" + Icons::ExclamationTriangle + "\\$z Thumbnail not found");
                } else {
                    UI::Text("\\$f00" + Icons::Times + "\\$z Error while loading thumbnail");
                }

                UI::EndTooltip();
            }
        }
    }
}
