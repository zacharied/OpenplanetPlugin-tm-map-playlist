namespace TM {
    class ClubActivity {
        string Name;
        string ClubName;
        int CampaignId;
        int ClubId;
        int ActivityId;
        int MapCount;
        string ThumbnailUrl;
        Campaign@ ActivityCampaign;

        ClubActivity(Json::Value@ json) {
            try {
                _Logging::Debug("Loading club activity information: " + Json::Write(json, true));

                Name = Text::OpenplanetFormatCodes(json["name"]);
                ClubName = Text::OpenplanetFormatCodes(json["clubName"]);
                MapCount = json["mapsCount"];
                ClubId = json["clubId"];
                ActivityId = json["activityId"];
                CampaignId = json["campaignId"];
                ThumbnailUrl = json["mediaUrlPngLarge"];
                @ActivityCampaign = Campaign(json["campaign"]);
            } catch {
                _Logging::Error("An error occurred while parsing the club activity info from Nadeo Services: " + getExceptionInfo(), true);
            }
        }
    }
}
