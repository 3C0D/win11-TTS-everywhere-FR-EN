; Module for managing the systray icon and menu

#Requires AutoHotkey v2.0
#Include "UIManager.ahk"
#Include "StartupManager.ahk"

; Function to initialize the systray menu
InitializeSystray() {
    ; Create tray icon - only needed if not compiled with an icon
    if (!A_IsCompiled)
        TraySetIcon(A_ScriptDir "\TTS.ico", , true)

    ; Create the systray menu
    A_TrayMenu.Delete()  ; Remove default options
    A_TrayMenu.Add("TTS Reader v" . APP_VERSION . " / Help", (*) => ShowHelp())
    A_TrayMenu.Add()  ; Separator
    A_TrayMenu.Add("Shortcuts...", (*) => ShowHelp())
    A_TrayMenu.Add()  ; Separator
    A_TrayMenu.Add("Run at startup", ToggleStartup)
    A_TrayMenu.Add()  ; Separator
    ; Add reload option only in development mode
    if (!A_IsCompiled) {
        A_TrayMenu.Add("Reload Script", (*) => Reload())
        A_TrayMenu.Add()  ; Separator
    }
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    A_TrayMenu.Default := "Shortcuts..."

    ; Check if already set to run at startup and update menu
    if (IsRunningAtStartup()) {
        A_TrayMenu.Check("Run at startup")
    } else {
        A_TrayMenu.Uncheck("Run at startup")
    }
}

; Function to update the systray menu item for startup
UpdateStartupMenuItem(isRunning) {
    if (isRunning) {
        A_TrayMenu.Check("Run at startup")
    } else {
        A_TrayMenu.Uncheck("Run at startup")
    }
}
