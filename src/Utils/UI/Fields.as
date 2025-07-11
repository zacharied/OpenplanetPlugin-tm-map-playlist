namespace UI {
    Source m_source = Source::TMX_Map_ID;

    string m_field = "";
    Campaign@ m_campaign;
    int m_clubId;
    int m_campaignId;

    void RenderSources() {
        UI::SetNextItemWidth(180);
        if (UI::BeginCombo("##AddSource", tostring(m_source).Replace("_", " "))) {
            for (uint i = 0; i < Source::Last; i++) {
                UI::PushID("SourceBtn" + i);

                if (UI::Selectable(tostring(Source(i)).Replace("_", " "), m_source == Source(i))) {
                    m_source = Source(i);
                    m_field = "";
                }

                UI::PopID();
            }

            UI::EndCombo();
        }

        UI::SameLine();

        switch (m_source) {
            case Source::Weekly_Shorts:
            case Source::Seasonal_Campaign:
            case Source::TOTD_Month:
                RenderDropdown();
                break;
            case Source::Club_Campaign:
                RenderClubCampaignFields();
                break;
            case Source::Favorites:
                RenderFavoritesButtons();
                break;
            default:
                RenderField();
                break;
        }
    }

    void RenderField() {
        bool pressedEnter = false;

        int inputFlags = UI::InputTextFlags::EnterReturnsTrue;
        UI::InputTextCallback@ callback;

        if (m_source == Source::TMX_Map_ID || m_source == Source::TMX_Mappack_ID) {
            inputFlags |= UI::InputTextFlags::CharsDecimal | UI::InputTextFlags::CallbackCharFilter | UI::InputTextFlags::CallbackAlways;
            @callback = UI::InputTextCallback(UI::IdCallback);
        }

        UI::SetNextItemWidth(200);
        m_field = UI::InputText("##SourceInput", m_field, pressedEnter, inputFlags, callback);

        UI::SameLine();

        UI::BeginDisabled(m_field.Length == 0);

        if (m_source == TMX_Mappack_ID && UI::Button("Select...##SelectMappackButton")) {
            startnew(CoroutineFuncUserdataInt64(playlist.SelectMappackAsync), Text::ParseInt(m_field));
            m_field = "";
        }

        UI::SameLine();

        if ((UI::Button("Add##AddButton") || pressedEnter) && m_field.Length > 0) {
            playlist.Add(m_source, m_field);
            m_field = "";
        }

        UI::EndDisabled();
    }

    void RenderDropdown() {
        array<Campaign@> campaigns = {};

        if (m_source == Source::Weekly_Shorts) {
            for (uint i = 0; i < WEEKLY_SHORTS.Length; i++) {
                campaigns.InsertLast(WEEKLY_SHORTS[i]);
            }
        } else if (m_source == Source::Seasonal_Campaign) {
            for (uint i = 0; i < SEASONAL_CAMPAIGNS.Length; i++) {
                campaigns.InsertLast(SEASONAL_CAMPAIGNS[i]);
            }
        } else if (m_source == Source::TOTD_Month) {
            for (uint i = 0; i < TOTD_MONTHS.Length; i++) {
                campaigns.InsertLast(TOTD_MONTHS[i]);
            }
        }

        UI::BeginDisabled(campaigns.IsEmpty());

        UI::SetNextItemWidth(130);
        if (UI::BeginCombo("##Campaigns", m_campaign is null ? "None" : m_campaign.Name)) {
            if (UI::Selectable("None", m_campaign is null)) {
                @m_campaign = null;
            }

            for (uint i = 0; i < campaigns.Length; i++) {
                UI::PushID("CampaignsBtn" + i);
                Campaign@ campaign = campaigns[i];

                if (UI::Selectable(campaign.Name, m_campaign !is null && m_campaign.Name == campaign.Name)) {
                    @m_campaign = campaign;
                }

                UI::PopID();
            }

            UI::EndCombo();
        }

        UI::EndDisabled();

        if (campaigns.IsEmpty()) UI::SetItemTooltip("Couldn't find any " + tostring(m_source).Replace("_", " ") + "\n\nPlugin might need to be reloaded.");

        UI::SameLine();

        UI::BeginDisabled(m_campaign is null);

        if (UI::Button("Select...") && m_campaign !is null) {
            Renderables::Add(SelectMaps(m_campaign));
            @m_campaign = null;
        }

        UI::SameLine();

        if (UI::Button("Add##CampaignButton") && m_campaign !is null) {
            playlist.Add(m_source, m_campaign);
            @m_campaign = null;
        }

        UI::EndDisabled();
    }

    void RenderClubCampaignFields() {
        UI::SetNextItemWidth(70);
        m_clubId = UI::InputInt("##ClubId", m_clubId, 0);
        UI::SetItemTooltip("Club ID");

        UI::SameLine();

        UI::SetNextItemWidth(70);
        m_campaignId = UI::InputInt("##CampaignId", m_campaignId, 0);
        UI::SetItemTooltip("Campaign ID");

        UI::SameLine();

        UI::BeginDisabled(m_clubId <= 0 || m_campaignId <= 0);

        array<int> ids = { m_clubId, m_campaignId };

        if (UI::Button("Select...##SelectMapsButton")) {
            startnew(CoroutineFuncUserdata(playlist.SelectCampaignMapsAsync), ids);
            m_clubId = 0;
            m_campaignId = 0;
        }

        UI::SameLine();

        if (UI::Button("Add##ClubCampaignButton")) {
            startnew(CoroutineFuncUserdata(playlist.AddCampaignAsync), ids);
            m_clubId = 0;
            m_campaignId = 0;
        }

        UI::EndDisabled();
    }

    void RenderFavoritesButtons() {
        UI::SameLine();

        UI::BeginDisabled(FAVORITES.IsEmpty());

        if (UI::Button("Select...##SelectFavorites")) {
            playlist.AddFavorites(true);
        }

        if (FAVORITES.IsEmpty()) UI::SetItemTooltip("You don't have any maps in your favorites\n\nIf you have added a map, reload the plugin.");

        UI::SameLine();

        if (UI::Button("Add##AddFavorites")) {
            playlist.AddFavorites();
        }

        if (FAVORITES.IsEmpty()) UI::SetItemTooltip("You don't have any maps in your favorites\n\nIf you have added a map, reload the plugin.");

        UI::EndDisabled();
    }
}
