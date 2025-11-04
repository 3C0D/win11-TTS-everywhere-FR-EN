#Requires AutoHotkey v2.0
#Include "StateManager.ahk"
#Include "VoiceManager.ahk"

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

; Global variable for minimized notification GUI
global minimizedGui := false

; Configuration for optimized drag handling
global DRAG_CONFIG := {
    saveDelay: 100,  ; Optimal delay for position saving after drag
    dragZoneHeight: 28  ; Height of the draggable zone (top area only)
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
    guiHeight := 70  ; Optimized height

    ; Utiliser la position sauvegardée dans l'objet state
    xPos := state.guiX
    yPos := state.guiY

    ; If no saved position, use default (top-right with 40px margin from edges)
    if (xPos == 0 && yPos == 0) {
        xPos := screenWidth - guiWidth - 60  ; 60px from right edge
        yPos := 40  ; 40px from top edge
    }

    ; Ensure the window is still visible on screen (in case of resolution change)
    if (xPos + guiWidth > screenWidth)
        xPos := screenWidth - guiWidth - 60
    if (yPos + guiHeight > screenHeight)
        yPos := screenHeight - guiHeight - 40
    if (xPos < 20)
        xPos := 20
    if (yPos < 20)
        yPos := 20

    ; Add minimize button in top-right corner
    controlGui.Add("Button", "x185 y5 w20 h18", "−").OnEvent("Click", MinimizeControlGui)

    ; Add buttons with icons using Unicode symbols
    buttonWidth := 30
    buttonHeight := 26  ; Slightly reduced height
    buttonOptions := "w" . buttonWidth . " h" . buttonHeight

    ; Previous paragraph button
    controlGui.Add("Button", "x15 y30 " . buttonOptions, "⏮").OnEvent("Click", JumpToPreviousParagraph)

    ; Play/Pause button
    global playPauseBtn  ; Make this global too
    playPauseBtn := controlGui.Add("Button", "x+10 y30 " . buttonOptions, state.isPaused ? "▶" : "⏸")
    playPauseBtn.OnEvent("Click", TogglePause)

    ; Stop button
    controlGui.Add("Button", "x+10 y30 " . buttonOptions, "⏹").OnEvent("Click", (*) => CloseControlGui())

    ; Next paragraph button
    controlGui.Add("Button", "x+10 y30 " . buttonOptions, "⏭").OnEvent("Click", JumpToNextLine)

    ; Settings button (gear icon)
    controlGui.Add("Button", "x+10 y30 " . buttonOptions, "⚙").OnEvent("Click", ToggleSettingsGui)

    ; Show the GUI - check if should start minimized
    if (state.startMinimized && !state.controlGuiVisible) {
        ; Start minimized - show and then minimize after a short delay
        controlGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight . " NoActivate")
        state.controlGuiVisible := true
        ; We use a timer to delay the minimization, preventing a focus issue.
        SetTimer(MinimizeControlGui, -50) ; Calls MinimizeControlGui once after 150ms
    } else {
        ; Show normally
        controlGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight . " NoActivate")
        state.controlGuiVisible := true
    }

    return controlGui
}

; Function to minimize the control GUI
MinimizeControlGui(*) {
    global controlGui

    if (controlGui && state.controlGuiVisible) {
        ; Hide the GUI instead of destroying it
        controlGui.Hide()
        state.controlGuiVisible := false
        
        ; Close settings GUI if it's open
        if (state.settingsGuiVisible) {
            CloseSettingsGui()
        }
        
        ; Show a small notification that can be clicked to restore
        ShowMinimizedNotification()
    }
}

; Function to show a small notification when minimized
ShowMinimizedNotification() {
    global minimizedGui
    
    ; Destroy existing notification if it exists
    if (minimizedGui) {
        try {
            minimizedGui.Destroy()
            minimizedGui := false
        } catch {
            ; Ignore errors
        }
    }
    
    ; Create a small notification GUI
    minimizedGui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20")
    minimizedGui.BackColor := "144d87"
    minimizedGui.SetFont("s12 cWhite Bold", "Segoe UI")
    minimizedGui.Add("Text", "x5 y2 w80 Center BackgroundTrans", "TTS Running").OnEvent("Click", RestoreControlGui)
    
    ; Position in top-right corner
    screenWidth := A_ScreenWidth
    minimizedGui.Show("x" . (screenWidth - 90) . " y10 w90 h20 NoActivate")
    WinSetTransparent(200, "ahk_id " . minimizedGui.Hwnd)
    
    ; Make the notification clickable
    OnMessage(0x201, MinimizedGuiClickHandler)
}

; Function to handle clicks on the minimized notification
MinimizedGuiClickHandler(wParam, lParam, msg, hwnd) {
    global minimizedGui
    
    if (minimizedGui && hwnd == minimizedGui.Hwnd) {
        RestoreControlGui()
        return 0
    }
}

; Function to restore the minimized GUI (you can call this from a hotkey or other trigger)
RestoreControlGui(*) {
    global controlGui, minimizedGui

    ; Hide the minimized notification
    CleanupMinimizedNotification()

    if (controlGui && !state.controlGuiVisible) {
        controlGui.Show("NoActivate")
        state.controlGuiVisible := true
    } else if (!controlGui && state.isReading) {
        ; Recreate GUI if it was destroyed but we're still reading
        CreateControlGui()
    }
}

; Function to clean up the minimized notification
CleanupMinimizedNotification() {
    global minimizedGui
    
    if (minimizedGui) {
        try {
            minimizedGui.Destroy()
            minimizedGui := false
            ; Remove the click handler
            OnMessage(0x201, MinimizedGuiClickHandler, 0)
        } catch {
            ; Ignore errors during cleanup
            minimizedGui := false
        }
    }
}

; Function to handle GUI dragging
GuiDragHandler(wParam, lParam, msg, hwnd) {
    global controlGui, dragState  ; Ensure we're using the global variables

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Get mouse position and control under cursor
    MouseGetPos(&mouseX, &mouseY, &mouseWin, &mouseCtrl)

    ; Only proceed if we're on the main control window
    if (mouseWin != controlGui.Hwnd)
        return

    ; Get relative mouse position within the window
    WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)
    relativeY := mouseY - winY

    ; Check if click is in the drag zone (top area only, excluding buttons)
    ; Drag zone is only the top 28 pixels and not on any control
    if (relativeY <= DRAG_CONFIG.dragZoneHeight && !mouseCtrl) {
        ; Start dragging
        dragState.isMouseDown := true
        dragState.initialX := mouseX
        dragState.initialY := mouseY
        dragState.initialWinX := winX
        dragState.initialWinY := winY

        ; Set up mouse move and button up handlers ONLY during drag
        OnMessage(0x200, GuiDragMoveHandler)  ; WM_MOUSEMOVE
        OnMessage(0x202, GuiDragReleaseHandler)  ; WM_LBUTTONUP

        return 0  ; Prevent default handling
    }

    ; If we're not in the drag zone, let the click pass through normally
    return
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

    ; Clean up minimized notification if it exists
    CleanupMinimizedNotification()

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

    ; Global variables to store references to controls
    global speedTextCtrl, volumeTextCtrl, languageDropDown, voiceENDropDown, voiceFRDropDown, settingsTab, startMinimizedCheckbox

    ; Destroy existing GUI if it exists
    if (settingsGui) {
        settingsGui.Destroy()
    }

    ; Get position of the main control GUI
    WinGetPos(&controlX, &controlY, &controlWidth, &controlHeight, "ahk_id " . controlGui.Hwnd)

    ; Create a new GUI with a compact style - increased height for new option
    settingsGui := Gui("+AlwaysOnTop +ToolWindow +Owner" . controlGui.Hwnd)
    settingsGui.Title := "Settings"
    settingsGui.SetFont("s10", "Segoe UI")
    settingsGui.OnEvent("Close", CloseSettingsGui)

    ; Create tab control - increased height
    settingsTab := settingsGui.Add("Tab3", "x5 y5 w205 h155", ["General", "Voices", "Shortcuts"])

    ; Tab 1: General settings
    settingsTab.UseTab(1)

    ; Add speed controls
    settingsGui.Add("Text", "x15 y35 w60", "Speed:")
    settingsGui.Add("Button", "x75 y33 w30 h25", "-").OnEvent("Click", (*) => AdjustSpeed(-0.5))
    speedTextCtrl := settingsGui.Add("Text", "x110 y35 w40 Center", state.speed)
    settingsGui.Add("Button", "x155 y33 w30 h25", "+").OnEvent("Click", (*) => AdjustSpeed(0.5))

    ; Add volume controls
    settingsGui.Add("Text", "x15 y65 w60", "Volume:")
    settingsGui.Add("Button", "x75 y63 w30 h25", "-").OnEvent("Click", (*) => AdjustVolume(-10))
    volumeTextCtrl := settingsGui.Add("Text", "x110 y65 w40 Center", state.volume)
    settingsGui.Add("Button", "x155 y63 w30 h25", "+").OnEvent("Click", (*) => AdjustVolume(10))

    ; Add language selection
    settingsGui.Add("Text", "x15 y95 w60", "Language:")
    languageDropDown := settingsGui.Add("DropDownList", "x80 y93 w100 Choose" . GetLanguageIndex(), ["Auto", "English",
        "Français"])
    languageDropDown.OnEvent("Change", OnLanguageChange)

    ; Add start minimized checkbox
    startMinimizedCheckbox := settingsGui.Add("Checkbox", "x15 y120 w175", "Start minimized (or Win+F don't forget it!)")
    startMinimizedCheckbox.Value := state.startMinimized
    startMinimizedCheckbox.OnEvent("Click", OnStartMinimizedChange)

    ; Tab 2: Voice settings
    settingsTab.UseTab(2)

    ; Get available voices
    availableVoices := GetAvailableVoices()

    ; Add English voice selection
    settingsGui.Add("Text", "x15 y35 w80", "English Voice:")
    enVoiceList := []
    enVoiceIndex := 1
    for i, voiceName in availableVoices.EN {
        displayName := GetVoiceDisplayName(voiceName)
        enVoiceList.Push(displayName)
        if (voiceName == state.selectedVoiceEN) {
            enVoiceIndex := i
        }
    }
    voiceENDropDown := settingsGui.Add("DropDownList", "x15 y55 w175 Choose" . enVoiceIndex, enVoiceList)
    voiceENDropDown.OnEvent("Change", OnVoiceENChange)

    ; Add French voice selection
    settingsGui.Add("Text", "x15 y85 w80", "French Voice:")
    frVoiceList := []
    frVoiceIndex := 1
    for i, voiceName in availableVoices.FR {
        displayName := GetVoiceDisplayName(voiceName)
        frVoiceList.Push(displayName)
        if (voiceName == state.selectedVoiceFR) {
            frVoiceIndex := i
        }
    }
    voiceFRDropDown := settingsGui.Add("DropDownList", "x15 y105 w175 Choose" . frVoiceIndex, frVoiceList)
    voiceFRDropDown.OnEvent("Change", OnVoiceFRChange)

    ; Tab 3: Shortcuts
    settingsTab.UseTab(3)
    
    ; Add shortcuts information (read-only) - adjusted for new height
    helpText := "
                (
                Win+Y: Start/Stop reading
                Win+Space: Pause/Resume
                Win+F: Show/Hide panel
                Win+N: Next §
                Win+P: Previous §
                Win+.: Cycle language
                Speed:  ↑ Numpad+
                        ↓ Numpad-
                Volume: ↑ Numpad*
                        ↓ Numpad/
                )"

    settingsGui.Add("Edit", "x10 y30 w190 h120 ReadOnly +VScroll", helpText)

    ; Reset tab selection
    settingsTab.UseTab()

    ; Calculate position (below the control GUI)
    settingsX := controlX
    settingsY := controlY + controlHeight

    ; Show the GUI with same width as control GUI - increased height
    settingsGui.Show("x" . settingsX . " y" . settingsY . " w215 h180 NoActivate")
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
    global speedTextCtrl, volumeTextCtrl, languageDropDown, startMinimizedCheckbox

    if (!state.settingsGuiVisible)
        return

    try {
        speedTextCtrl.Text := state.speed
        volumeTextCtrl.Text := state.volume
        languageDropDown.Choose(GetLanguageIndex())
        if (startMinimizedCheckbox)
            startMinimizedCheckbox.Value := state.startMinimized
    } catch as err {
        OutputDebug("Error updating settings values: " . err.Message)
    }
}

; Function to handle start minimized checkbox change
OnStartMinimizedChange(*) {
    global startMinimizedCheckbox

    if (startMinimizedCheckbox) {
        state.startMinimized := startMinimizedCheckbox.Value
        
        ; Save settings to INI file
        SaveVoiceSettings()
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

    ; Save settings to INI file
    SaveVoiceSettings()
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

    ; Save settings to INI file
    SaveVoiceSettings()
}

; Function to display a temporary speed window
ShowSpeedWindow() {
    ; Create a temporary GUI to show the current speed
    speedGui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20")
    speedGui.BackColor := "333333"
    speedGui.SetFont("s17 c00FF00 Bold", "Segoe UI")
    speedGui.Add("Text", "x10 y10", "Speed: " . state.speed)

    ; Position in the center of the screen
    speedGui.Show("w180 h50 NoActivate")
    WinSetTransparent(200, "ahk_id " . speedGui.Hwnd)

    ; Auto-close after a short delay
    SetTimer(() => speedGui.Destroy(), -1500)
}

; Function to display a temporary volume window
ShowVolumeWindow() {
    ; Create a temporary GUI to show the current volume
    volumeGui := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20")
    volumeGui.BackColor := "333333"
    volumeGui.SetFont("s17 c00FF00 Bold", "Segoe UI")
    volumeGui.Add("Text", "x10 y10", "Volume: " . state.volume)

    ; Position in the center of the screen
    volumeGui.Show("w180 h50 NoActivate")
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
    Win+Space : Pause/Resume reading

    NAVIGATION:
    Win+N : Skip to next paragraph (Next)
    Win+P : Go to previous paragraph (Previous)

    LANGUAGE:
    Win+. : Cycle through languages (Auto -> English -> French)

    SPEED:
    Numpad+ : Increase speed
    Numpad- : Decrease speed

    VOLUME:
    Numpad* : Increase volume
    Numpad/ : Decrease volume

    CONTROL INTERFACE:
    Win+F : Show/Hide control panel (Full screen toggle)

    When reading starts, a control panel appears with:
    − : Minimize control panel (click notification to restore)
    ⏮ : Go to previous paragraph
    ⏸/▶ : Pause/Resume reading
    ⏹ : Stop reading
    ⏭ : Skip to next paragraph
    ⚙ : Open settings (speed, volume, voices, and shortcuts)

    The control panel can be moved by dragging the top area (title bar).
    It closes automatically when reading stops.
    Use Win+F to toggle the control panel visibility.
    Click on the top area of the control panel to close settings if they're open.

    === Settings Panel ===
    The settings panel has three tabs:
    • General: Adjust speed, volume, language detection, and startup options
    • Voices: Select preferred voices for English and French
    • Shortcuts: View all available keyboard shortcuts

    === How to use ===
    1. Select or copy text in any application
    2. Press Win+Y to start reading
    3. Use the shortcuts or control panel to control playback
    4. Press Win+. to cycle through language modes during reading
    5. Press Win+F to hide/show the control panel during reading
    6. Access settings via the gear (⚙) button for voice and language preferences
    7. Drag the control panel by its top area to reposition it

    By default, language is automatically detected (English or French).
    You can select your preferred voice for each language in the Voices tab of the settings.
    All shortcuts are listed in the Shortcuts tab for easy reference.
    You can set the application to start minimized in the General tab.
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

    ; Save settings to INI file
    SaveVoiceSettings()

    ; If currently reading, change language on the fly
    if (state.isReading) {
        ChangeLanguageOnTheFly(newLanguage)
    }
}

; Function to handle English voice selection change
OnVoiceENChange(*) {
    global voiceENDropDown

    if (!voiceENDropDown)
        return

    selectedIndex := voiceENDropDown.Value
    availableVoices := GetAvailableVoices()

    if (selectedIndex > 0 && selectedIndex <= availableVoices.EN.Length) {
        state.selectedVoiceEN := availableVoices.EN[selectedIndex]

        ; If reading is in progress and current language is English, apply voice change immediately
        if (state.isReading && !state.isPaused) {
            currentLanguage := (state.languageMode == "AUTO") ? DetermineDominantLanguage(state.originalText) : state.languageMode
            if (currentLanguage == "EN") {
                ; Stop current reading completely
                voice.Speak("", 3)

                ; Apply new voice and restart reading from current text
                SetVoiceLanguage("EN", state.currentText)
                voice.Rate := state.internalRate
                voice.Volume := state.volume
                voice.Speak(state.currentText, 1)  ; Restart reading with new voice

                ; Update control GUI
                UpdateControlGui()
            }
        }

        ; Save settings to INI file
        SaveVoiceSettings()
    }
}

; Function to handle French voice selection change
OnVoiceFRChange(*) {
    global voiceFRDropDown

    if (!voiceFRDropDown)
        return

    selectedIndex := voiceFRDropDown.Value
    availableVoices := GetAvailableVoices()

    if (selectedIndex > 0 && selectedIndex <= availableVoices.FR.Length) {
        state.selectedVoiceFR := availableVoices.FR[selectedIndex]

        ; If reading is in progress and current language is French, apply voice change immediately
        if (state.isReading && !state.isPaused) {
            currentLanguage := (state.languageMode == "AUTO") ? DetermineDominantLanguage(state.originalText) : state.languageMode
            if (currentLanguage == "FR") {
                ; Stop current reading completely
                voice.Speak("", 3)

                ; Apply new voice and restart reading from current text
                SetVoiceLanguage("FR", state.currentText)
                voice.Rate := state.internalRate
                voice.Volume := state.volume
                voice.Speak(state.currentText, 1)  ; Restart reading with new voice

                ; Update control GUI
                UpdateControlGui()
            }
        }

        ; Save settings to INI file
        SaveVoiceSettings()
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