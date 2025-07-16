void Main() {
    if (!HAS_PERMISSIONS) {
        _Logging::Error("You don't have enough permissions to use this plugin!", true);

        Meta::Plugin@ self = Meta::ExecutingPlugin();
        Meta::UnloadPlugin(self);
    }

    Saves::LoadPlaylists();

    NadeoServices::AddAudience("NadeoLiveServices");

    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        yield();
    }

    if (!S_SkipLoad) {
        TM::GetWeeklyShorts();
        TM::GetSeasonalCampaigns();
        TM::GetFavorites();
        TM::GetTOTDMonths();
    }
}

[Setting hidden]
bool showMainWindow = true;

void RenderMenu() {
    if (HAS_PERMISSIONS && UI::MenuItem(FULL_NAME, "", showMainWindow)) {
        showMainWindow = !showMainWindow;
    }
}

void Render() {
    if (!HAS_PERMISSIONS || (S_HideWithOP && !UI::IsOverlayShown()) || (S_HideWithGameUI && !UI::IsGameUIVisible())) {
        return;
    }

    UI::RenderMainWindow();

    Renderables::Render();
}

bool held = false;

void OnKeyPress(bool down, VirtualKey key) {
    if (!HAS_PERMISSIONS || playlist.IsEmpty() || TM::IsLoadingMap()) return;

    if (!held && key == S_SwitchKey) {
        playlist.NextMap();
    }

    held = down;
}
