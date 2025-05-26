#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "VoiceInitializer.ahk"
#Include "TextProcessor.ahk"
#Include "HotkeyManager.ahk"
#Include "UIManager.ahk"
#Include "SystrayManager.ahk"
#Include "StartupManager.ahk"
#Include "ClipboardManager.ahk"
#Include "StateManager.ahk"

; Define version first
global APP_VERSION := "1.1.1"

; Debug message
if (!A_IsCompiled) {
    MsgBox("TTS.ahk script loaded - Version: " . APP_VERSION . " - " . FormatTime(, "HH:mm:ss"))
}

; Shortcut for development only
if (!A_IsCompiled) {
    #!r:: Reload()  ; Win+Alt+R to reload the script
}

; Initialize Windows voices
InitializeVoices()

global voice := ComObject("SAPI.SpVoice")
global controlGui := false  ; Will hold the control GUI instance
global settingsGui := false  ; Will hold the settings GUI instance

; Load saved settings from INI file
LoadVoiceSettings()

InitializeSystray()

; Initialize all hotkeys
InitializeHotkeys()
; Disable hotkeys at start
UpdateHotkeys(false)

ReadText() {

    if (voice.Status.RunningState == 2 || state.isPaused) {
        StopReading()
        return
    }

    text := getSelOrCbText()
    if (text == "")
        return

    state.originalText := IgnoreCharacters(text)

    ; Split text into paragraphs
    state.paragraphs := SplitIntoParagraphs(state.originalText)

    ; Start with the first paragraph
    state.currentParagraphIndex := 1
    state.currentText := state.paragraphs[state.currentParagraphIndex]

    try {
        ; Use the selected language mode from settings
        SetVoiceLanguage(state.languageMode, state.originalText)
        voice.Rate := state.internalRate
        voice.Volume := state.volume  ; Ensure volume is applied before reading

        state.isReading := true
        ; Enable hotkeys when reading starts
        UpdateHotkeys(true)
        voice.Speak(state.currentText, 1)  ; Asynchronous reading

        ; Show the control GUI
        CreateControlGui()

        ; Initialize the last position values for reference
        WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)
        dragState.lastSavedX := winX
        dragState.lastSavedY := winY

        ; Update state with current position
        state.guiX := winX
        state.guiY := winY

        ; Monitor reading status
        SetTimer(CheckReadingStatus, 100)
    } catch as err {
        MsgBox "Error using text-to-speech: " . err.Message
        ResetState()
    }
}

CheckReadingStatus() {
    if (voice.Status.RunningState == 1) { ; If reading is complete
        ; Check if there are more paragraphs to read
        if (state.currentParagraphIndex < state.paragraphs.Length) {
            ; Move to the next paragraph
            state.currentParagraphIndex++

            ; Get the text of the next paragraph
            nextParagraphText := state.paragraphs[state.currentParagraphIndex]

            if (nextParagraphText != "") {
                ; Update current text and start new reading
                state.currentText := nextParagraphText

                ; Use the selected language mode for each paragraph
                SetVoiceLanguage(state.languageMode, nextParagraphText)

                voice.Rate := state.internalRate
                voice.Volume := state.volume
                voice.Speak(nextParagraphText, 1)  ; Start new asynchronous reading
                return
            }
        }

        ; If we reached here, there are no more paragraphs to read
        StopReading()
        SetTimer(CheckReadingStatus, 0) ; Stop the timer
    }
}
