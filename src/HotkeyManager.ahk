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
        Hotkey "#^y", "On"              ; Next line
        Hotkey "#+y", "On"              ; Previous paragraph
        Hotkey "#!y", "On"              ; Pause/Resume
    } else {
        ; Speed and volume controls
        Hotkey "NumpadAdd", "Off"
        Hotkey "NumpadSub", "Off"
        Hotkey "NumpadMult", "Off"     ; Volume Up
        Hotkey "NumpadDiv", "Off"      ; Volume Down

        ; Navigation and control hotkeys
        Hotkey "#^y", "Off"             ; Next line
        Hotkey "#+y", "Off"             ; Previous paragraph
        Hotkey "#!y", "Off"             ; Pause/Resume
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
    }
}

; Toggle pause/resume function
TogglePause(*) {
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

; Initialize hotkeys
InitializeHotkeys() {
    ; Speed and volume controls
    Hotkey "NumpadAdd", AdjustSpeedUp
    Hotkey "NumpadSub", AdjustSpeedDown
    Hotkey "NumpadMult", VolumeUp
    Hotkey "NumpadDiv", VolumeDown

    ; Navigation and control hotkeys
    Hotkey "#^y", JumpToNextLine
    Hotkey "#+y", JumpToPreviousParagraph
    Hotkey "#!y", TogglePause

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
        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(state.currentText, 1)  ; Asynchronous reading
    } else {
        ; If at first paragraph, restart it
        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(state.currentText, 1)  ; Asynchronous reading
    }
}

; Main function to start reading selected text
ReadSelectedText(*) {
    ; Auto-detect language
    ReadText("AUTO")
}
