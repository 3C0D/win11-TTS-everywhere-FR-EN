; Module for managing startup settings

#Requires AutoHotkey v2.0

; Function to check if the script is running at startup
IsRunningAtStartup() {
    startupPath := A_Startup "\TTS Reader.lnk"
    return FileExist(startupPath)
}

; Function to toggle startup status
ToggleStartup(*) {
    startupPath := A_Startup "\TTS Reader.lnk"

    if (IsRunningAtStartup()) {
        ; Remove from startup
        try {
            FileDelete(startupPath)
            ; Need to update systray menu item
            UpdateStartupMenuItem(false)
        } catch as err {
            MsgBox("Error removing startup shortcut: " . err.Message)
        }
    } else {
        ; Add to startup
        try {
            if A_IsCompiled {
                FileCreateShortcut(A_ScriptFullPath, startupPath, A_WorkingDir)
            } else {
                FileCreateShortcut(A_AhkPath, startupPath, A_WorkingDir, '"' . A_ScriptFullPath . '"')
            }
            ; Need to update systray menu item
            UpdateStartupMenuItem(true)
        } catch as err {
            MsgBox("Error creating startup shortcut: " . err.Message)
        }
    }
}
