#Requires AutoHotkey v2.0
#Include "UIManager.ahk"
#Include "SystrayManager.ahk"

; Module for managing hotkeys and keyboard shortcuts

; Manage hotkeys
UpdateHotkeys(enable := true) {
    if (enable) {
        ; Speed and volume controls
        Hotkey "NumpadAdd", "On"
        Hotkey "NumpadSub", "On"
        Hotkey "NumpadMult", "On"      ; Volume Up
        Hotkey "NumpadDiv", "On"       ; Volume Down

        ; Navigation and control hotkeys
        Hotkey "#n", "On"               ; Next paragraph (Win+N)
        Hotkey "#p", "On"               ; Previous paragraph (Win+P)
        Hotkey "#!", "On"               ; Pause/Resume (Win+Alt)
        Hotkey "#f", "On"               ; Show/Hide control GUI (Win+F for "full screen toggle")
    } else {
        ; Speed and volume controls
        Hotkey "NumpadAdd", "Off"
        Hotkey "NumpadSub", "Off"
        Hotkey "NumpadMult", "Off"     ; Volume Up
        Hotkey "NumpadDiv", "Off"      ; Volume Down

        ; Navigation and control hotkeys
        Hotkey "#n", "Off"              ; Next paragraph
        Hotkey "#p", "Off"              ; Previous paragraph
        Hotkey "#!", "Off"              ; Pause/Resume
        Hotkey "#f", "Off"              ; Show/Hide control GUI
    }
}

; Speed adjustment functions
AdjustSpeedUp(*) {
    AdjustSpeed(0.5)
}

AdjustSpeedDown(*) {
    AdjustSpeed(-0.5)
}

; Volume adjustment functions
VolumeUp(*) {
    if (state.volume < 100) {
        state.volume += 10
        voice.Volume := state.volume
        ShowVolumeWindow()

        ; Force update of settings GUI if it's visible
        if (state.settingsGuiVisible) {
            UpdateSettingsValues()
        }

        ; Save settings to INI file
        SaveVoiceSettings()
    }
}

VolumeDown(*) {
    if (state.volume > 0) {
        state.volume -= 10
        voice.Volume := state.volume
        ShowVolumeWindow()

        ; Force update of settings GUI if it's visible
        if (state.settingsGuiVisible) {
            UpdateSettingsValues()
        }

        ; Save settings to INI file
        SaveVoiceSettings()
    }
}

; Function to toggle control GUI visibility
ToggleControlGui(*) {
    global controlGui

    if (!state.isReading) {
        return  ; Don't show GUI if not reading
    }

    if (state.controlGuiVisible) {
        ; If GUI is visible, minimize it
        MinimizeControlGui()
    } else {
        ; If GUI is hidden, restore it
        RestoreControlGui()
    }
}

; Initialize hotkeys
InitializeHotkeys() {
    ; Speed and volume controls
    Hotkey "NumpadAdd", AdjustSpeedUp
    Hotkey "NumpadSub", AdjustSpeedDown
    Hotkey "NumpadMult", VolumeUp
    Hotkey "NumpadDiv", VolumeDown

    ; Navigation and control hotkeys
    Hotkey "#n", JumpToNextLine        ; Win+N for Next
    Hotkey "#p", JumpToPreviousParagraph  ; Win+P for Previous
    Hotkey "#!", TogglePause           ; Win+Alt for Pause/Resume
    Hotkey "#f", ToggleControlGui      ; Win+F to show/hide control GUI

    ; Main hotkey to start reading
    Hotkey "#y", ReadSelectedText
}

; Navigation functions
JumpToNextLine(*) {
    ; Do nothing if reading is paused
    if (state.isPaused)
        return

    ; Check if we are already at the last paragraph
    if (state.currentParagraphIndex >= state.paragraphs.Length) {
        ; We are already at the last paragraph, do nothing
        return
    }

    ; Stop the current reading completely (necessary to reset SAPI state)
    voice.Speak("", 3)  ; SVSFPurgeBeforeSpeak (stops immediately)

    ; Move to the next paragraph
    state.currentParagraphIndex++

    ; Get the text of the next paragraph
    nextParagraphText := state.paragraphs[state.currentParagraphIndex]

    if (nextParagraphText != "") {
        ; Update current text and start new reading
        state.currentText := nextParagraphText

        ; Use the selected language mode from settings
        ; We pass the original text to maintain language consistency
        SetVoiceLanguage(state.languageMode, state.originalText)

        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(nextParagraphText, 1)  ; Start new asynchronous reading
    } else {
        StopReading()  ; If no more text, stop reading
    }
}

JumpToPreviousParagraph(*) {
    if (!state.isReading) {
        return
    }

    ; Stop current reading
    voice.Speak("", 3)

    ; Move to previous paragraph if possible
    if (state.currentParagraphIndex > 1) {
        state.currentParagraphIndex--
        state.currentText := state.paragraphs[state.currentParagraphIndex]

        ; Use the selected language mode from settings
        ; We pass the original text to maintain language consistency
        SetVoiceLanguage(state.languageMode, state.originalText)

        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(state.currentText, 1)  ; Asynchronous reading
    } else {
        ; If at first paragraph, restart it

        ; Use the selected language mode from settings
        ; We pass the original text to maintain language consistency
        SetVoiceLanguage(state.languageMode, state.originalText)

        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(state.currentText, 1)  ; Asynchronous reading
    }
}

; Main function to start reading selected text
ReadSelectedText(*) {
    ; Use the selected language mode from settings
    ReadText()
}