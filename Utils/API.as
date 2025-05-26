namespace API {
    Net::HttpRequest@ Get(const string &in url) {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Get;
        ret.Url = url;

        _Logging::Debug("Starting HTTP request: " + url);

        ret.Start();
        return ret;
    }

    Json::Value GetAsync(const string &in url) {
        auto req = Get(url);

        while (!req.Finished()) {
            yield();
        }

        auto json = req.Json();
        _Logging::Debug("HTTP request result: " + Json::Write(json, true));

        return req.Json();
    }
}