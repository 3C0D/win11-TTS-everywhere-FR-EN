﻿#Requires AutoHotkey v2.0

InitializeVoices() {
    ; First check if voices are missing without admin rights
    sourcePath := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens"
    destinationPaths := [
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices\Tokens",
        "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\SPEECH\Voices\Tokens"
    ]

    ; Check for missing voices in registry
    missingVoices := false
    oneCoreVoices := []
    standardVoices := []

    ; Get list of OneCore voices
    try {
        loop reg, sourcePath, "K" {
            oneCoreVoices.Push(A_LoopRegName)
        }
    }

    ; Get list of standard voices
    try {
        loop reg, destinationPaths[1], "K" {
            standardVoices.Push(A_LoopRegName)
        }
    }

    ; Compare voice counts
    if (oneCoreVoices.Length > standardVoices.Length) {
        missingVoices := true
    }

    ; Exit if no voices need to be installed
    if (!missingVoices)
        return

    ; Request admin rights if needed
    if !A_IsAdmin {
        MsgBox(
            "Des voix supplémentaires sont disponibles. Le script va redémarrer avec les droits administrateur pour les installer."
        )
        try {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            ExitApp
        }
        catch {
            MsgBox("Impossible d'obtenir les droits administrateur. Certaines voix pourraient ne pas être disponibles."
            )
            return
        }
    }

    ; Copy registry keys and update voices
    try {
        voicesAdded := 0

        for destPath in destinationPaths {
            for voiceName in oneCoreVoices {
                sourceKey := sourcePath "\" voiceName
                destKey := destPath "\" voiceName

                ; Check if voice already exists in destination
                try {
                    existingValue := RegRead(destKey)
                    continue  ; Voice already exists, skip
                } catch {
                    ; Voice doesn't exist, create it
                    try {
                        RegCreateKey(destKey)

                        ; Copy all values from source to destination
                        loop reg, sourceKey, "V" {
                            RegWrite(RegRead(sourceKey, A_LoopRegName), "REG_SZ", destKey, A_LoopRegName)
                        }

                        ; Also copy subkeys if any
                        loop reg, sourceKey, "K" {
                            subSourceKey := sourceKey "\" A_LoopRegName
                            subDestKey := destKey "\" A_LoopRegName

                            RegCreateKey(subDestKey)

                            loop reg, subSourceKey, "V" {
                                RegWrite(RegRead(subSourceKey, A_LoopRegName), "REG_SZ", subDestKey, A_LoopRegName)
                            }
                        }

                        voicesAdded++
                    } catch as err {
                        ; Continue with next voice if one fails
                        OutputDebug("Error copying voice " voiceName ": " err.Message)
                    }
                }
            }
        }

        ; Also create compatibility mappings for easier access
        compatibilityMappings := Map(
            "MSTTS_V110_frFR_HortenseM", "TTS_MS_FR-FR_HORTENSE_11.0",
            "MSTTS_V110_frFR_JulieM", "TTS_MS_FR-FR_JULIE_11.0",
            "MSTTS_V110_frFR_PaulM", "TTS_MS_FR-FR_PAUL_11.0",
            "MSTTS_V110_enUS_ZiraM", "TTS_MS_EN-US_ZIRA_11.0",
            "MSTTS_V110_enUS_DavidM", "TTS_MS_EN-US_DAVID_11.0",
            "MSTTS_V110_enUS_MarkM", "TTS_MS_EN-US_MARK_11.0"
        )

        for oneCoreKey, compatKey in compatibilityMappings {
            sourceKey := sourcePath "\" oneCoreKey

            ; Check if source exists
            try {
                RegRead(sourceKey)

                ; Create compatibility mapping in both destinations
                for destPath in destinationPaths {
                    destKey := destPath "\" compatKey

                    ; Skip if already exists
                    try {
                        RegRead(destKey)
                    } catch {
                        try {
                            RegCreateKey(destKey)

                            ; Copy values
                            loop reg, sourceKey, "V" {
                                RegWrite(RegRead(sourceKey, A_LoopRegName), "REG_SZ", destKey, A_LoopRegName)
                            }

                            ; Copy subkeys
                            loop reg, sourceKey, "K" {
                                subSourceKey := sourceKey "\" A_LoopRegName
                                subDestKey := destKey "\" A_LoopRegName

                                RegCreateKey(subDestKey)

                                loop reg, subSourceKey, "V" {
                                    RegWrite(RegRead(subSourceKey, A_LoopRegName), "REG_SZ", subDestKey, A_LoopRegName)
                                }
                            }

                            voicesAdded++
                        } catch as err {
                            OutputDebug("Error creating compatibility mapping for " compatKey ": " err.Message)
                        }
                    }
                }
            } catch {
                ; Source doesn't exist, skip
                continue
            }
        }

        ; Restart audio service to apply changes
        if (voicesAdded > 0) {
            RunWait("net stop Audiosrv", , "Hide")
            RunWait("net start Audiosrv", , "Hide")

            MsgBox(voicesAdded " voix supplémentaires ont été installées. L'application va redémarrer.")
            Reload
        } else {
            MsgBox("Aucune nouvelle voix n'a été installée.")
        }
    }
    catch as err {
        MsgBox("Erreur lors de la mise à jour des voix: " err.Message)
    }
}

; Uncomment to enable voice initialization
InitializeVoices()

; Global variables
global APP_VERSION := "1.0.6"  ; Updated from 1.0.5 to 1.0.6
global state := {
    isReading: false,
    isPaused: false,
    speed: 2.0,  ; Speed for display
    internalRate: 2, ; Integer speed for SAPI
    currentText: "",   ; Current text being read
    originalText: "",  ; Original complete text
    volume: 100,     ; Volume level (0-100)
    controlGuiVisible: false  ; Track if control GUI is visible
}

global voice := ComObject("SAPI.SpVoice")
global controlGui := false  ; Will hold the control GUI instance

; Create tray icon - only needed if not compiled with an icon
if (!A_IsCompiled)
    TraySetIcon(A_ScriptDir "\TTS.ico", , true)

A_TrayMenu.Delete()  ; Remove default options
A_TrayMenu.Add("TTS Reader v" . APP_VERSION, (*) => ShowHelp())
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("Shortcuts...", (*) => ShowHelp())
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("Run at startup", ToggleStartup)
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Shortcuts..."

; Check if already set to run at startup and update menu
startupPath := A_Startup "\TTS Reader.lnk"
if FileExist(startupPath)
    A_TrayMenu.Check("Run at startup")

; Function to toggle startup status
ToggleStartup(*) {
    startupPath := A_Startup "\TTS Reader.lnk"

    if FileExist(startupPath) {
        ; Remove from startup
        try {
            FileDelete(startupPath)
            A_TrayMenu.Uncheck("Run at startup")
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
            A_TrayMenu.Check("Run at startup")
        } catch as err {
            MsgBox("Error creating startup shortcut: " . err.Message)
        }
    }
}
; A_TrayMenu.Add("Play/Stop (Win+Y)", (*) => ReadText("AUTO"))
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Shortcuts..."

; Function to display shortcuts help
ShowHelp(*) {
    helpText := "
    (
    MAIN SHORTCUTS:
    Win+Y : Play/Stop selected text
    Win+Alt+Y : Pause/Resume reading

    NAVIGATION:
    Win+Ctrl+Y : Skip to next paragraph
    Win+Shift+Y : Go to previous paragraph

    SPEED:
    Numpad+ : Increase speed
    Numpad- : Decrease speed

    VOLUME:
    Numpad* : Increase volume
    Numpad/ : Decrease volume

    CONTROL INTERFACE:
    When reading starts, a control panel appears with:
    ⏮ : Go to previous paragraph
    ⏸/▶ : Pause/Resume reading
    ⏹ : Stop reading
    ⏭ : Skip to next paragraph

    The control panel can be moved by dragging it.
    It closes automatically when reading stops.

    === How to use ===
    1. Select or copy text in any application
    2. Press Win+Y to start reading
    3. Use the shortcuts or control panel to control playback

    Language is automatically detected (English or French).
    )"

    helpGui := Gui("+AlwaysOnTop")
    helpGui.Title := "Shortcuts"
    helpGui.SetFont("s10", "Segoe UI")
    helpGui.Add("Text", "w500", helpText)
    helpGui.Add("Button", "Default w100", "OK").OnEvent("Click", (*) => helpGui.Destroy())
    helpGui.Show()
}

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

; Initialize hotkeys
Hotkey "NumpadAdd", AdjustSpeedUp
Hotkey "NumpadSub", AdjustSpeedDown
Hotkey "NumpadMult", VolumeUp
Hotkey "NumpadDiv", VolumeDown
Hotkey "#^y", JumpToNextLine
Hotkey "#+y", JumpToPreviousParagraph
Hotkey "#!y", TogglePause
; Disable hotkeys at start
UpdateHotkeys(false)

; play/stop
#y:: ReadText("AUTO")

; Function to jump to the next line
JumpToNextLine(*) {
    ; Do nothing if reading is paused
    if (state.isPaused)
        return

    ; Get the currently reading text
    text := state.currentText

    ; Get the current position in the text
    currentPos := voice.Status.InputWordPosition

    ; Search for the next line after the current position
    nextPos := -1
    nextPos := InStr(text, "`n", true, currentPos + 1)

    ; If a valid position is found
    if (nextPos > 0) {
        ; Stop the current reading
        voice.Speak("", 3)  ; 3 = SVSFPurgeBeforeSpeak (stops immediately)

        ; Extract remaining text starting just after the line break
        remainingText := SubStr(text, nextPos + 1)

        ; Remove any initial line breaks if present
        remainingText := RegExReplace(remainingText, "^[\r\n]+", "")

        ; Resume reading with the remaining text
        if (remainingText != "") {
            state.currentText := remainingText
            voice.Rate := state.internalRate
            voice.Speak(remainingText, 1)  ; 1 = SVSFlagsAsync (asynchronous reading)
        } else {
            StopReading()  ; If no more text, stop reading
        }
    }
}

; pause/resume
#!y:: TogglePause()

; Function to jump to the previous paragraph
JumpToPreviousParagraph(*) {
    if (state.isPaused)
        return

    ; Static variables to track jumps and timing
    static lastJumpTime := 0
    static lastPosition := 0
    static currentParagraphStart := 0
    static isFirstJump := true

    currentTime := A_TickCount
    timeSinceLastJump := currentTime - lastJumpTime

    ; Calculate the actual position in the original text
    currentPosInCurrent := voice.Status.InputWordPosition
    currentTextStart := InStr(state.originalText, state.currentText)
    currentPos := currentTextStart + currentPosInCurrent

    ; Check if we're within the time window for quick jumps
    isQuickClick := timeSinceLastJump < 1500

    ; Record the time of this jump
    lastJumpTime := currentTime

    ; Stop the current reading completely (necessary to reset SAPI state)
    voice.Speak("", 3)  ; SVSFPurgeBeforeSpeak (stops immediately)

    ; Determine where to jump
    if (isQuickClick && !isFirstJump) {
        ; For quick clicks after the first jump, go to previous paragraph
        ; Start searching from before the current paragraph start
        searchPos := currentParagraphStart - 1

        ; If we're already at the beginning, stay there
        if (searchPos < 1) {
            newPos := 1
        } else {
            ; Find the previous line break
            newPos := InStr(SubStr(state.originalText, 1, searchPos), "`n", , -1)

            ; If no previous line break found, go to the beginning
            if (!newPos)
                newPos := 1
        }

        ; Update the current paragraph start for next jump
        currentParagraphStart := newPos
    } else {
        ; For first click or slow clicks, find the beginning of the current sentence/paragraph
        ; Look for the previous line break before the current position
        newPos := InStr(SubStr(state.originalText, 1, currentPos), "`n", , -1)

        ; If no line break found, go to the beginning of the text
        if (!newPos)
            newPos := 1

        ; Store this position as the current paragraph start
        currentParagraphStart := newPos
        isFirstJump := false
    }

    ; Reset first jump flag if it's not a quick click
    if (!isQuickClick) {
        isFirstJump := true
    }

    ; Create new text starting from the calculated position
    remainingText := SubStr(state.originalText, newPos)
    remainingText := RegExReplace(remainingText, "^[\r\n]+", "")

    if (remainingText != "") {
        ; Update current text and start new reading
        state.currentText := remainingText
        voice.Rate := state.internalRate
        voice.Speak(remainingText, 1)  ; Start new asynchronous reading
    } else {
        StopReading()
    }
}

; Helper function to find paragraph boundaries in text
FindParagraphBoundaries(text) {
    boundaries := []

    ; Always include the start of the text
    startPos := 1

    ; Scan through the text to find paragraph boundaries
    searchPos := 1
    textLength := StrLen(text)

    while (searchPos <= textLength) {
        ; Look for paragraph breaks (double newlines)
        paragraphBreak := InStr(text, "`n`n", false, searchPos)

        ; If no more paragraph breaks, the end of text is the last boundary
        if (!paragraphBreak) {
            ; Add the final paragraph
            boundaries.Push({ start: startPos, end: textLength + 1 })
            break
        }

        ; Add this paragraph boundary
        boundaries.Push({ start: startPos, end: paragraphBreak + 2 })

        ; Skip past any consecutive newlines
        newPos := paragraphBreak + 2
        while (SubStr(text, newPos, 1) == "`n" && newPos <= textLength) {
            newPos++
        }

        ; Start of next paragraph
        startPos := newPos
        searchPos := newPos
    }

    ; If no paragraphs were found (no double newlines), treat the entire text as one paragraph
    if (boundaries.Length == 0) {
        boundaries.Push({ start: 1, end: textLength + 1 })
    }

    return boundaries
}
AdjustSpeedUp(*) {
    AdjustSpeed(0.5)
}

AdjustSpeedDown(*) {
    AdjustSpeed(-0.5)
}

; Helper function for clipboard operations (we copy it there again needed for compilation .exe)
getSelOrCbText() {
    OldClipboard := A_Clipboard
    A_Clipboard := ""

    Send "^c" ; Copy the selected text
    if !ClipWait(1.0) {
        ; If no selection, restore the clipboard and use it
        if (OldClipboard != "") {
            text := OldClipboard
            A_Clipboard := OldClipboard
            return text
        } else {
            MsgBox "No text selected or in the clipboard"
            return ""
        }
    } else {
        ; Use the selected text
        text := A_Clipboard
        A_Clipboard := OldClipboard
        return text
    }
}

ReadText(language) {
    if (voice.Status.RunningState == 2 || state.isPaused) {
        StopReading()
        return
    }

    ResetState()

    text := getSelOrCbText()
    if (text == "")
        return

    state.currentText := text
    state.originalText := text  ; Store the original text
    state.currentText := IgnoreCharacters(state.currentText)
    state.originalText := IgnoreCharacters(state.originalText)

    try {
        SetVoiceLanguage(language, state.currentText)
        voice.Rate := state.internalRate

        state.isReading := true
        ; Enable hotkeys when reading starts
        UpdateHotkeys(true)
        voice.Speak(state.currentText, 1)  ; Asynchronous reading

        ; Show the control GUI
        CreateControlGui()

        ; Monitor reading status
        SetTimer(CheckReadingStatus, 100)
    } catch as err {
        MsgBox "Error using text-to-speech: " . err.Message
        ResetState()
    }
}

CheckReadingStatus() {
    if (voice.Status.RunningState == 1) { ; If reading is complete
        StopReading()
        SetTimer(CheckReadingStatus, 0) ; Stop the timer
    }
}

AdjustSpeed(delta) {
    if (!state.isReading)
        return

    ; Update display speed
    state.speed := Max(Min(state.speed + delta, 10), -10)
    state.speed := Round(state.speed, 1)

    ; Convert to integer for SAPI
    state.internalRate := Round(state.speed)
    voice.Rate := state.internalRate

    ; Display the speed window
    ShowSpeedWindow()
}

ShowSpeedWindow() {
    static speedGui := false

    ; Destroy existing window if present
    if (speedGui) {
        speedGui.Destroy()
    }

    ; Create a new window
    speedGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    speedGui.SetFont("s12", "Arial")
    speedGui.Add("Text", , "Speed: " . Format("{:.1f}", state.speed))
    ; Position the window
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight
    guiWidth := 150
    guiHeight := 40
    xPos := (screenWidth - guiWidth) / 2
    yPos := screenHeight - 100

    speedGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight)

    ; Close the window after 2 seconds
    SetTimer () => speedGui.Destroy(), -2000
}

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

ResetState() {
    state.isReading := false
    state.isPaused := false
    UpdateHotkeys(false)
}

StopReading() {
    global controlGui  ; Ensure we're using the global variable

    if (state.isPaused) {
        voice.Resume()
        state.isPaused := false
    }
    voice.Speak("", 3)  ; Stop current reading
    state.currentText := "" ; Reset text
    ResetState()

    ; Close the control GUI if it's open
    if (state.controlGuiVisible) {
        CloseControlGui()
    }
}

SetVoiceLanguage(language, text := "") {
    if (language == "AUTO") {
        language := DetectLanguage(text)
    }

    if (language == "EN") {
        voiceName := "Microsoft Mark"
    } else if (language == "FR") {
        voiceName := "Microsoft Paul"
    } else {
        MsgBox "Unsupported language: " . language
        return
    }

    for v in voice.GetVoices() {
        if (v.GetAttribute("Name") == voiceName) {
            voice.Voice := v
            return
        }
    }

    MsgBox "Voice for language " . language . " not found. Using default voice."
}

DetectLanguage(text) {
    ; Language detection based on common words and patterns
    frenchWords := ["le", "la", "les", "un", "une", "des", "et", "ou", "mais", "donc", "or", "ni", "car", "que", "qui",
        "quoi", "dont", "où", "à", "au", "avec", "pour", "sur", "dans", "par", "ce", "cette", "ces", "je", "tu", "il",
        "elle",
        "nous", "vous", "ils", "elles", "mon", "ton", "son", "notre", "votre", "leur"
    ]
    englishWords := ["the", "and", "or", "but", "so", "yet", "for", "nor", "that", "which", "who", "whom", "whose",
        "when", "where", "why", "how", "a", "an", "in", "on", "at", "with", "by", "this", "these", "those", "is", "are",
        "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "shall",
        "should"
    ]

    ; Add weight to more distinctive words
    distinctiveFrench := ["est", "sont", "être", "avoir", "fait", "très", "beaucoup", "toujours", "jamais"]
    distinctiveEnglish := ["is", "are", "be", "have", "do", "very", "much", "always", "never"]

    frenchScore := 0
    englishScore := 0

    ; Count French-specific characters (adds to French score)
    frenchChars := "éèêëàâäôöùûüçÉÈÊËÀÂÄÔÖÙÛÜÇ"
    for char in StrSplit(text) {
        if InStr(frenchChars, char)
            frenchScore += 0.5  ; Give moderate weight to accented characters
    }

    ; Split text into words, normalize to lowercase for accurate counting
    words := StrSplit(StrLower(text), " ")
    for word in words {
        ; Check regular words
        if (HasVal(frenchWords, word))
            frenchScore++
        if (HasVal(englishWords, word))
            englishScore++

        ; Give extra weight to distinctive words
        if (HasVal(distinctiveFrench, word))
            frenchScore += 2
        if (HasVal(distinctiveEnglish, word))
            englishScore += 2
    }

    ; Check for language-specific patterns
    if (RegExMatch(text, "i)qu'[aeiouy]|c'est|n'[aeiouy]|l'[aeiouy]|d'[aeiouy]"))
        frenchScore += 3
    if (RegExMatch(text, "i)ing\s|ed\s|'s\s|'ve\s|'re\s|'ll\s"))
        englishScore += 3

    ; Determine the language based on score
    if (englishScore > frenchScore) {
        return "EN"
    } else {
        return "FR" ; Defaults to French if scores are equal or French is higher
    }
}

HasVal(haystack, needle) {
    ; Checks if a list contains a specific word
    for index, value in haystack
        if (value = needle)
            return true
    return false
}

IgnoreCharacters(text) {
    ; Removes specific characters from text
    charactersToIgnore := ["*", " #", "##", "# ", "\n#", "@", "//", "/"]
    for char in charactersToIgnore {
        text := StrReplace(text, char, "")
    }
    return text
}

VolumeUp(*) {
    if (state.volume < 100) {
        state.volume += 10
        voice.Volume := state.volume
        ShowVolumeWindow()
    }
}

VolumeDown(*) {
    if (state.volume > 0) {
        state.volume -= 10
        voice.Volume := state.volume
        ShowVolumeWindow()
    }
}

ShowVolumeWindow() {
    static volumeGui := false

    ; Destroy existing window if present
    if (volumeGui) {
        volumeGui.Destroy()
    }

    ; Create a new window
    volumeGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    volumeGui.SetFont("s12", "Arial")
    volumeGui.Add("Text", , "Volume: " . state.volume . "%")

    ; Position the window
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight
    guiWidth := 150
    guiHeight := 40
    xPos := (screenWidth - guiWidth) / 2
    yPos := screenHeight - 100

    volumeGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight)

    ; Close the window after 2 seconds
    SetTimer () => volumeGui.Destroy(), -2000
}

; Create and show the control interface GUI
CreateControlGui() {
    global controlGui  ; Ensure we're using the global variable

    ; Destroy existing GUI if it exists
    if (controlGui) {
        controlGui.Destroy()
    }

    ; Create a new GUI with a compact style
    controlGui := Gui("+AlwaysOnTop +LastFound +ToolWindow")
    controlGui.Title := "TTS"
    controlGui.SetFont("s10", "Segoe UI")
    controlGui.OnEvent("Close", CloseControlGui)

    ; Make the GUI draggable without click-through style
    OnMessage(0x201, GuiDragHandler)  ; WM_LBUTTONDOWN message

    ; Calculate position (top-right corner, 100px from top and right)
    screenWidth := A_ScreenWidth
    guiWidth := 200
    guiHeight := 60
    xPos := screenWidth - guiWidth - 100
    yPos := 100

    ; Add buttons with icons using Unicode symbols
    buttonWidth := 30
    buttonHeight := 30
    buttonOptions := "w" . buttonWidth . " h" . buttonHeight

    ; Previous paragraph button
    controlGui.Add("Button", "x15 y15 " . buttonOptions, "⏮").OnEvent("Click", (*) => JumpToPreviousParagraph())

    ; Play/Pause button
    global playPauseBtn  ; Make this global too
    playPauseBtn := controlGui.Add("Button", "x+10 y15 " . buttonOptions, state.isPaused ? "▶" : "⏸")
    playPauseBtn.OnEvent("Click", TogglePause)

    ; Stop button
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⏹").OnEvent("Click", (*) => CloseControlGui())

    ; Next paragraph button
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⏭").OnEvent("Click", (*) => JumpToNextLine())

    ; Show the GUI
    controlGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight . " NoActivate")
    state.controlGuiVisible := true

    return controlGui
}

; Variables for GUI dragging
global dragState := {
    isMouseDown: false,
    initialX: 0,
    initialY: 0,
    initialWinX: 0,
    initialWinY: 0
}

; Function to handle GUI dragging
GuiDragHandler(wParam, lParam, msg, hwnd) {
    global controlGui, dragState  ; Ensure we're using the global variables

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Get mouse position and control under cursor
    MouseGetPos(&mouseX, &mouseY, &mouseWin, &mouseCtrl)

    ; Only start dragging if we're on the window and not on a control
    ; This allows dragging from the title bar or empty space, but not from buttons
    if (mouseWin != controlGui.Hwnd || mouseCtrl)
        return

    ; Start dragging
    dragState.isMouseDown := true
    dragState.initialX := mouseX
    dragState.initialY := mouseY

    ; Get window position
    WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)
    dragState.initialWinX := winX
    dragState.initialWinY := winY

    ; Set up mouse move and button up handlers
    OnMessage(0x200, GuiDragMoveHandler)  ; WM_MOUSEMOVE
    OnMessage(0x202, GuiDragReleaseHandler)  ; WM_LBUTTONUP

    return 0  ; Prevent default handling
}

; Function to handle GUI dragging movement
GuiDragMoveHandler(wParam, lParam, msg, hwnd) {
    global controlGui, dragState  ; Ensure we're using the global variables

    if (!dragState.isMouseDown || !controlGui || !state.controlGuiVisible)
        return

    ; Get current mouse position
    MouseGetPos(&mouseX, &mouseY)

    ; Calculate new window position
    newX := dragState.initialWinX + (mouseX - dragState.initialX)
    newY := dragState.initialWinY + (mouseY - dragState.initialY)

    ; Move the window
    WinMove(newX, newY, , , "ahk_id " . controlGui.Hwnd)

    return 0
}

; Function to handle GUI drag release
GuiDragReleaseHandler(wParam, lParam, msg, hwnd) {
    global controlGui, dragState  ; Ensure we're using the global variables

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Stop dragging
    dragState.isMouseDown := false

    ; Remove handlers
    OnMessage(0x200, GuiDragMoveHandler, 0)  ; Remove WM_MOUSEMOVE handler
    OnMessage(0x202, GuiDragReleaseHandler, 0)  ; Remove WM_LBUTTONUP handler

    return 0
}

; Function to close the control GUI
CloseControlGui(*) {
    global controlGui  ; Ensure we're using the global variable

    if (controlGui) {
        controlGui.Destroy()
        controlGui := false
        state.controlGuiVisible := false
    }

    ; If we're closing the GUI, also stop reading
    if (state.isReading) {
        StopReading()
    }
}

; Function to update the control GUI (e.g., when pausing/resuming)
UpdateControlGui() {
    global controlGui  ; Ensure we're using the global variable

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Update play/pause button text based on current state
    try {
        ; Recreate the GUI to update the button state
        CreateControlGui()
    } catch as err {
        OutputDebug("Error updating control GUI: " . err.Message)
    }
}
