#Requires AutoHotkey v2.0

; Module for managing UI elements and interactions

; Variables for GUI dragging and position tracking
global dragState := {
    isMouseDown: false,
    initialX: 0,
    initialY: 0,
    initialWinX: 0,
    initialWinY: 0,
    lastSavedX: 0,  ; last saved X position
    lastSavedY: 0   ; last saved Y position
}

; Configuration for optimized drag handling
global DRAG_CONFIG := {
    saveDelay: 100  ; Optimal delay for position saving after drag
}

; Create and show the control interface GUI
CreateControlGui() {
    global controlGui  ; Ensure we're using the global variable

    ; Remove any existing mouse message handlers to prevent duplicates
    OnMessage(0x201, GuiDragHandler, 0)  ; Remove WM_LBUTTONDOWN handler
    OnMessage(0x200, GuiDragMoveHandler, 0)  ; Remove WM_MOUSEMOVE handler
    OnMessage(0x202, GuiDragReleaseHandler, 0)  ; Remove WM_LBUTTONUP handler

    ; Destroy existing GUI if it exists
    if (controlGui) {
        controlGui.Destroy()
    }

    ; Create a new GUI with a compact style
    controlGui := Gui("+AlwaysOnTop +LastFound +ToolWindow")
    controlGui.Title := "TTS"
    controlGui.SetFont("s10", "Segoe UI")
    controlGui.OnEvent("Close", CloseControlGui)

    ; Make the GUI draggable - only WM_LBUTTONDOWN handler at startup
    OnMessage(0x201, GuiDragHandler)  ; WM_LBUTTONDOWN message

    ; Calculate position (use saved position or default to top-right corner)
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight
    guiWidth := 215  ; Increased width to accommodate the settings button
    guiHeight := 60

    ; Utiliser la position sauvegardée dans l'objet state
    xPos := state.guiX
    yPos := state.guiY

    ; Ensure the window is still visible on screen (in case of resolution change)
    if (xPos + guiWidth > screenWidth)
        xPos := screenWidth - guiWidth - 20
    if (yPos + guiHeight > screenHeight)
        yPos := screenHeight - guiHeight - 20
    if (xPos < 0)
        xPos := 20
    if (yPos < 0)
        yPos := 20

    ; Add buttons with icons using Unicode symbols
    buttonWidth := 30
    buttonHeight := 28
    buttonOptions := "w" . buttonWidth . " h" . buttonHeight

    ; Previous paragraph button
    controlGui.Add("Button", "x15 y15 " . buttonOptions, "⏮").OnEvent("Click", JumpToPreviousParagraph)

    ; Play/Pause button
    global playPauseBtn  ; Make this global too
    playPauseBtn := controlGui.Add("Button", "x+10 y15 " . buttonOptions, state.isPaused ? "▶" : "⏸")
    playPauseBtn.OnEvent("Click", TogglePause)

    ; Stop button
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⏹").OnEvent("Click", (*) => CloseControlGui())

    ; Next paragraph button
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⏭").OnEvent("Click", JumpToNextLine)

    ; Settings button (gear icon)
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⚙").OnEvent("Click", ToggleSettingsGui)

    ; Show the GUI
    controlGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight . " NoActivate")
    state.controlGuiVisible := true

    return controlGui
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

    ; Set up mouse move and button up handlers ONLY during drag
    OnMessage(0x200, GuiDragMoveHandler)  ; WM_MOUSEMOVE
    OnMessage(0x202, GuiDragReleaseHandler)  ; WM_LBUTTONUP

    return 0  ; Prevent default handling
}

; Function to handle GUI drag release
GuiDragReleaseHandler(wParam, lParam, msg, hwnd) {
    global controlGui, dragState, state  ; Ensure we're using the global variables

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Stop dragging
    dragState.isMouseDown := false

    ; Save the current position of the window
    WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)

    ; Update position in state object
    state.guiX := winX
    state.guiY := winY
    dragState.lastSavedX := winX
    dragState.lastSavedY := winY

    OutputDebug("Position updated in state: X=" winX ", Y=" winY)

    ; Remove handlers immediately after drag ends
    OnMessage(0x200, GuiDragMoveHandler, 0)  ; Remove WM_MOUSEMOVE handler
    OnMessage(0x202, GuiDragReleaseHandler, 0)  ; Remove WM_LBUTTONUP handler

    return 0
}

; Function to handle GUI dragging movement
GuiDragMoveHandler(wParam, lParam, msg, hwnd) {
    global controlGui, settingsGui, dragState, state  ; Ensure we're using the global variables

    if (!dragState.isMouseDown || !controlGui || !state.controlGuiVisible)
        return

    ; Get current mouse position
    MouseGetPos(&mouseX, &mouseY, &mouseWin)

    ; Make sure we're still over our window
    if (mouseWin != controlGui.Hwnd)
        return

    ; Calculate new window position
    newX := dragState.initialWinX + (mouseX - dragState.initialX)
    newY := dragState.initialWinY + (mouseY - dragState.initialY)

    ; Ensure the window stays within screen boundaries
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight

    ; Get window dimensions
    WinGetPos(, , &winWidth, &winHeight, "ahk_id " . controlGui.Hwnd)

    ; Adjust position if needed to keep window on screen
    if (newX < 0)
        newX := 0
    if (newY < 0)
        newY := 0
    if (newX + winWidth > screenWidth)
        newX := screenWidth - winWidth
    if (newY + winHeight > screenHeight)
        newY := screenHeight - winHeight

    ; Move the window
    WinMove(newX, newY, , , "ahk_id " . controlGui.Hwnd)

    ; Update state immediately during drag
    state.guiX := newX
    state.guiY := newY

    ; If settings GUI is open, move it to follow the main GUI
    if (settingsGui && state.settingsGuiVisible) {
        ; Calculate new position for settings GUI (below the main GUI)
        settingsX := newX
        settingsY := newY + winHeight

        ; Move the settings GUI
        WinMove(settingsX, settingsY, , , "ahk_id " . settingsGui.Hwnd)
    }

    return 0
}

; Function to close the control GUI
CloseControlGui(*) {
    global controlGui, dragState, state  ; Ensure we're using the global variables

    ; Final position save before closing
    if (controlGui && state.controlGuiVisible) {
        try {
            WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)
            state.guiX := winX
            state.guiY := winY
        } catch OSError {
            ; Keep previous values if error
        }
    }

    ; Remove all message handlers
    OnMessage(0x201, GuiDragHandler, 0)  ; Remove WM_LBUTTONDOWN handler
    OnMessage(0x200, GuiDragMoveHandler, 0)  ; Remove WM_MOUSEMOVE handler
    OnMessage(0x202, GuiDragReleaseHandler, 0)  ; Remove WM_LBUTTONUP handler

    ; Reset drag state
    dragState.isMouseDown := false

    ; Close the settings GUI if it's open
    if (state.settingsGuiVisible) {
        CloseSettingsGui()
    }

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
    global controlGui, playPauseBtn  ; Ensure we're using the global variables

    if (!controlGui || !state.controlGuiVisible || !playPauseBtn)
        return

    ; Update play/pause button text based on current state without recreating the GUI
    try {
        ; Just update the button text
        playPauseBtn.Text := state.isPaused ? "▶" : "⏸"
    } catch as err {
        OutputDebug("Error updating control GUI: " . err.Message)

        ; If updating fails, recreate the GUI as a fallback
        try {
            CreateControlGui()
        } catch {
            ; If even recreation fails, just ignore
        }
    }
}

; Function to toggle the settings GUI
ToggleSettingsGui(*) {
    global settingsGui

    if (state.settingsGuiVisible) {
        CloseSettingsGui()
    } else {
        CreateSettingsGui()
    }
}

; Function to create the settings GUI
CreateSettingsGui() {
    global settingsGui, controlGui

    ; Variables globales pour stocker les références aux contrôles de texte
    global speedTextCtrl, volumeTextCtrl, languageDropDown

    ; Destroy existing GUI if it exists
    if (settingsGui) {
        settingsGui.Destroy()
    }

    ; Get position of the main control GUI
    WinGetPos(&controlX, &controlY, &controlWidth, &controlHeight, "ahk_id " . controlGui.Hwnd)

    ; Create a new GUI with a compact style
    settingsGui := Gui("+AlwaysOnTop +ToolWindow +Owner" . controlGui.Hwnd)
    settingsGui.Title := "Settings"
    settingsGui.SetFont("s10", "Segoe UI")
    settingsGui.OnEvent("Close", CloseSettingsGui)

    ; Add speed controls
    settingsGui.Add("Text", "x10 y10 w60", "Speed:")
    settingsGui.Add("Button", "x70 y8 w30 h25", "-").OnEvent("Click", (*) => AdjustSpeed(-0.5))
    speedTextCtrl := settingsGui.Add("Text", "x105 y10 w40 Center", state.speed)
    settingsGui.Add("Button", "x150 y8 w30 h25", "+").OnEvent("Click", (*) => AdjustSpeed(0.5))

    ; Add volume controls
    settingsGui.Add("Text", "x10 y40 w60", "Volume:")
    settingsGui.Add("Button", "x70 y38 w30 h25", "-").OnEvent("Click", (*) => AdjustVolume(-10))
    volumeTextCtrl := settingsGui.Add("Text", "x105 y40 w40 Center", state.volume)
    settingsGui.Add("Button", "x150 y38 w30 h25", "+").OnEvent("Click", (*) => AdjustVolume(10))

    ; Add language selection
    settingsGui.Add("Text", "x10 y70 w60", "Language:")
    languageDropDown := settingsGui.Add("DropDownList", "x75 y68 w100 Choose" . GetLanguageIndex(), ["Auto", "English",
        "Français"])
    languageDropDown.OnEvent("Change", OnLanguageChange)

    ; Calculate position (below the control GUI)
    settingsX := controlX
    settingsY := controlY + controlHeight

    ; Show the GUI
    settingsGui.Show("x" . settingsX . " y" . settingsY . " w190 h105 NoActivate")
    state.settingsGuiVisible := true
}

; Function to close the settings GUI
CloseSettingsGui(*) {
    global settingsGui

    if (settingsGui) {
        settingsGui.Destroy()
        settingsGui := false
        state.settingsGuiVisible := false
    }
}

; Function to update the settings values
UpdateSettingsValues() {
    global speedTextCtrl, volumeTextCtrl, languageDropDown

    if (!state.settingsGuiVisible)
        return

    try {
        speedTextCtrl.Text := state.speed
        volumeTextCtrl.Text := state.volume
        languageDropDown.Choose(GetLanguageIndex())
    } catch as err {
        OutputDebug("Error updating settings values: " . err.Message)
    }
}

; Function to adjust volume
AdjustVolume(delta) {
    if (!state.isReading)
        return

    ; Update volume (ensure it stays within 0-100 range)
    state.volume := Max(Min(state.volume + delta, 100), 0)
    voice.Volume := state.volume

    ; Display the volume window
    ShowVolumeWindow()

    ; Force update of settings GUI if it's visible
    if (state.settingsGuiVisible) {
        UpdateSettingsValues()
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

    ; Force update of settings GUI if it's visible
    if (state.settingsGuiVisible) {
        UpdateSettingsValues()
    }
}

; Function to display a temporary speed window
ShowSpeedWindow() {
    ; Create a temporary GUI to show the current speed
    speedGui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20")
    speedGui.BackColor := "333333"
    speedGui.SetFont("s14 c00FF00 Bold", "Segoe UI")
    speedGui.Add("Text", "x10 y10", "Speed: " . state.speed)

    ; Position in the center of the screen
    speedGui.Show("w150 h40 NoActivate")
    WinSetTransparent(200, "ahk_id " . speedGui.Hwnd)

    ; Auto-close after a short delay
    SetTimer(() => speedGui.Destroy(), -1500)
}

; Function to display a temporary volume window
ShowVolumeWindow() {
    ; Create a temporary GUI to show the current volume
    volumeGui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20")
    volumeGui.BackColor := "333333"
    volumeGui.SetFont("s14 c00FF00 Bold", "Segoe UI")
    volumeGui.Add("Text", "x10 y10", "Volume: " . state.volume)

    ; Position in the center of the screen
    volumeGui.Show("w150 h40 NoActivate")
    WinSetTransparent(200, "ahk_id " . volumeGui.Hwnd)

    ; Auto-close after a short delay
    SetTimer(() => volumeGui.Destroy(), -1500)
}

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
    ⚙ : Open settings (speed, volume, and language)

    The control panel can be moved by dragging it.
    It closes automatically when reading stops.

    === How to use ===
    1. Select or copy text in any application
    2. Press Win+Y to start reading
    3. Use the shortcuts or control panel to control playback
    4. Change the reading language in the settings menu if needed.

    By default, language is automatically detected (English or French).
    )"

    helpGui := Gui("+AlwaysOnTop")
    helpGui.Title := "Help"
    helpGui.SetFont("s10", "Segoe UI")
    helpGui.Add("Text", "w500", helpText)
    helpGui.Add("Button", "Default w100", "OK").OnEvent("Click", (*) => helpGui.Destroy())
    helpGui.Show()
}

; Function to get the current language index for the dropdown
GetLanguageIndex() {
    switch state.languageMode {
        case "AUTO":
            return 1
        case "EN":
            return 2
        case "FR":
            return 3
        default:
            return 1
    }
}

; Function to handle language change from dropdown
OnLanguageChange(*) {
    global languageDropDown, voice, state

    ; Get selected language
    selectedIndex := languageDropDown.Value
    switch selectedIndex {
        case 1:
            newLanguage := "AUTO"
        case 2:
            newLanguage := "EN"
        case 3:
            newLanguage := "FR"
        default:
            newLanguage := "AUTO"
    }

    ; Update state
    state.languageMode := newLanguage

    ; If currently reading, change language on the fly
    if (state.isReading) {
        ChangeLanguageOnTheFly(newLanguage)
    }
}

; Function to change language during reading
ChangeLanguageOnTheFly(newLanguage) {
    global voice, state

    ; Store current reading position and state
    wasReading := state.isReading
    wasPaused := state.isPaused
    currentText := state.currentText
    currentParagraphIndex := state.currentParagraphIndex

    ; Stop current reading
    if (wasPaused) {
        voice.Resume()
        state.isPaused := false
    }
    voice.Speak("", 3)  ; Stop immediately

    ; Set new voice language
    SetVoiceLanguage(newLanguage, currentText)

    ; Apply current settings
    voice.Rate := state.internalRate
    voice.Volume := state.volume

    ; Resume reading from current position if it was reading
    if (wasReading && !wasPaused) {
        voice.Speak(currentText, 1)  ; Resume asynchronous reading
    }
}
