enum LogLevel {
    Error,
    Warn,
    Info,
    Debug,
    Trace
}

namespace _Logging {
    void Error(const string &in msg, bool showNotification = false) {
        if (S_LogLevel >= LogLevel::Error) {
            if (showNotification) {
                vec4 color = UI::HSV(1.0, 1.0, 1.0);
                UI::ShowNotification(PLUGIN_NAME + " - Error", msg, color, 8000);
            }

            error("[ERROR] " + msg);
        }
    }

    void Warn(const string &in msg, bool showNotification = false) {
        if (S_LogLevel >= LogLevel::Warn) {
            if (showNotification) {
                vec4 color = UI::HSV(0.11, 1.0, 1.0);
                UI::ShowNotification(PLUGIN_NAME + " - Warning", msg, color, 5000);
            }

            warn("[WARN] " + msg);
        }
    }

    void Info(const string &in msg) {
        if (S_LogLevel >= LogLevel::Info) {
            print("[INFO] " + msg);
        }
    }

    void Debug(const string &in msg) {
        if (S_LogLevel >= LogLevel::Debug) {
            trace("[DEBUG] " + msg);
        }
    }

    void Trace(const string &in msg) {
        if (S_LogLevel >= LogLevel::Trace) {
            trace("[TRACE] " + msg);
        }
    }
}
