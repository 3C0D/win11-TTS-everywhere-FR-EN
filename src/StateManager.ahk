; Module for managing global state and related functions

#Requires AutoHotkey v2.0
#Include "HotkeyManager.ahk"
#Include "UIManager.ahk" ; Added for UpdateControlGui()

; Global state object
state := {
    isReading: false,
    isPaused: false,
    speed: 2.5,
    internalRate: 2,
    currentText: "",
    originalText: "",
    paragraphs: [],
    currentParagraphIndex: 0,
    volume: 100,
    controlGuiVisible: false,
    settingsGuiVisible: false,
    guiX: A_ScreenWidth - 300,
    guiY: 100
}

; Reset the state to initial values
ResetState() {
    global state
    state.isReading := false
    state.isPaused := false
    state.paragraphs := []
    state.currentParagraphIndex := 0
    state.originalText := ""
    UpdateHotkeys(false)
}

; Stop reading and reset state
StopReading() {
    global state, voice
    if (state.isPaused) {
        voice.Resume()
        state.isPaused := false
    }
    voice.Speak("", 3)
    state.currentText := ""
    ResetState()
    SetTimer(MonitorWindowPosition, 0)
    if (state.settingsGuiVisible) {
        CloseSettingsGui()
    }
    if (state.controlGuiVisible) {
        CloseControlGui()
    }
}

; Toggle pause/resume function
TogglePause(*) {
    global state, voice ; Added global voice
    if (!state.isReading) {
        return
    }

    if (!state.isPaused) {
        voice.Pause()
        state.isPaused := true
    } else {
        voice.Resume()
        state.isPaused := false
    }

    ; Update the control GUI to reflect the new state
    UpdateControlGui()
}
