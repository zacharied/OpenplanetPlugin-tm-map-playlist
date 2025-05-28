[Setting name="Switch Map Hotkey" category="General" description="Hotkey used to move to the next map."]
VirtualKey S_SwitchKey = VirtualKey(0);

[Setting name="Load in editor" category="General" description="If enabled, maps will be loaded in the editor."]
bool S_Editor = false;

[Setting name="Show/Hide with Openplanet overlay" category="General"]
bool S_HideWithOP = true;

[Setting name="Show/Hide with game UI" category="General"]
bool S_HideWithGameUI = true;

[Setting name="Loop playlist" category="General" description="When enabled, the playlist will start again after reaching the last map."]
bool S_Loop = false;

[Setting name="Display colored map names" category="General"]
bool S_ColoredNames = false;

[Setting name="Log level" category="Dev"]
LogLevel S_LogLevel = LogLevel::Info;
