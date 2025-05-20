#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "VoiceInitializer.ahk"
#Include "TextProcessor.ahk"
#Include "HotkeyManager.ahk"
#Include "UIManager.ahk"

; Todo: Videz les variables inutiles quand on stoppe. Pour ne pas les garder en mémoire
; Ajoutez Des options de choix de langue. Ça pourrait être dans le systray.
; Améliorer la détection des langues.

; Définir la version en premier
global APP_VERSION := "1.0.9"

; Message de débogage
if (!A_IsCompiled) {
    MsgBox("TTS.ahk script loaded - Version: " . APP_VERSION . " - " . FormatTime(, "HH:mm:ss"))
}

; Raccourci pour le développement uniquement
if (!A_IsCompiled) {
    #!r:: Reload()  ; Win+Alt+R pour recharger le script
}

; Initialisation des voix Windows
InitializeVoices()

; Global variables
global state := {
    isReading: false,
    isPaused: false,
    speed: 2.5,  ; Speed for display
    internalRate: 2, ; Integer speed for SAPI
    currentText: "",   ; Current text being read
    originalText: "",  ; Original complete text
    paragraphs: [],    ; Liste des paragraphes du texte
    currentParagraphIndex: 0, ; Index du paragraphe actuel
    volume: 100,     ; Volume level (0-100)
    controlGuiVisible: false,  ; Track if control GUI is visible
    settingsGuiVisible: false, ; Track if settings GUI is visible
    guiX: A_ScreenWidth - 300, ; Position X de la fenêtre (marge à droite)
    guiY: 100                  ; Position Y de la fenêtre (marge en haut)
}

global voice := ComObject("SAPI.SpVoice")
global controlGui := false  ; Will hold the control GUI instance
global settingsGui := false  ; Will hold the settings GUI instance

; Create tray icon - only needed if not compiled with an icon
if (!A_IsCompiled)
    TraySetIcon(A_ScriptDir "\TTS.ico", , true)

; Créer le menu de la barre d'état système
A_TrayMenu.Delete()  ; Remove default options
A_TrayMenu.Add("TTS Reader v" . APP_VERSION . " / Help", (*) => ShowHelp())
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("Shortcuts...", (*) => ShowHelp())
A_TrayMenu.Add()  ; Separator
A_TrayMenu.Add("Run at startup", ToggleStartup)

; Ajouter l'option de rechargement uniquement en mode développement
if (!A_IsCompiled) {
    A_TrayMenu.Add()  ; Separator
    A_TrayMenu.Add("Reload Script", (*) => Reload())
}

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
    ⚙ : Open settings (speed and volume)

    The control panel can be moved by dragging it.
    It closes automatically when reading stops.

    === How to use ===
    1. Select or copy text in any application
    2. Press Win+Y to start reading
    3. Use the shortcuts or control panel to control playback

    Language is automatically detected (English or French).
    )"

    helpGui := Gui("+AlwaysOnTop")
    helpGui.Title := "Help"
    helpGui.SetFont("s10", "Segoe UI")
    helpGui.Add("Text", "w500", helpText)
    helpGui.Add("Button", "Default w100", "OK").OnEvent("Click", (*) => helpGui.Destroy())
    helpGui.Show()
}

; Initialize all hotkeys
InitializeHotkeys()
; Disable hotkeys at start
UpdateHotkeys(false)

; play/stop
; Main hotkey is now handled by HotkeyManager

; Function to jump to the next paragraph - moved to HotkeyManager.ahk

; pause/resume
; Hotkey is now handled by HotkeyManager

; Function to jump to the previous paragraph - moved to HotkeyManager.ahk

; Helper function to find paragraph boundaries in text
; FindParagraphBoundaries(text) {
;     boundaries := []

;     ; Always include the start of the text
;     startPos := 1

;     ; Scan through the text to find paragraph boundaries
;     searchPos := 1
;     textLength := StrLen(text)

;     while (searchPos <= textLength) {
;         ; Look for paragraph breaks (double newlines)
;         paragraphBreak := InStr(text, "`n`n", false, searchPos)

;         ; If no more paragraph breaks, the end of text is the last boundary
;         if (!paragraphBreak) {
;             ; Add the final paragraph
;             boundaries.Push({ start: startPos, end: textLength + 1 })
;             break
;         }

;         ; Add this paragraph boundary
;         boundaries.Push({ start: startPos, end: paragraphBreak + 2 })

;         ; Skip past any consecutive newlines
;         newPos := paragraphBreak + 2
;         while (SubStr(text, newPos, 1) == "`n" && newPos <= textLength) {
;             newPos++
;         }

;         ; Start of next paragraph
;         startPos := newPos
;         searchPos := newPos
;     }

;     ; If no paragraphs were found (no double newlines), treat the entire text as one paragraph
;     if (boundaries.Length == 0) {
;         boundaries.Push({ start: 1, end: textLength + 1 })
;     }

;     return boundaries
; }

; Function to adjust speed is now defined in UIManager.ahk

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
        trimmedClipboard := RegExReplace(A_Clipboard, "[\s\r\n]+", "")
        if (trimmedClipboard != "") {
            text := A_Clipboard
        } else {
            text := OldClipboard
            A_Clipboard := OldClipboard
        }
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

    state.originalText := IgnoreCharacters(text)

    ; Diviser le texte en paragraphes
    state.paragraphs := SplitIntoParagraphs(state.originalText)

    ; Commencer par le premier paragraphe
    state.currentParagraphIndex := 1
    state.currentText := state.paragraphs[state.currentParagraphIndex]

    try {
        SetVoiceLanguage(language, state.currentText)
        voice.Rate := state.internalRate
        voice.Volume := state.volume  ; S'assurer que le volume est appliqué avant la lecture

        state.isReading := true
        ; Enable hotkeys when reading starts
        UpdateHotkeys(true)
        voice.Speak(state.currentText, 1)  ; Asynchronous reading

        ; Show the control GUI
        CreateControlGui()

        ; Initialiser les valeurs de la dernière position
        WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)
        dragState.lastSavedX := winX
        dragState.lastSavedY := winY

        ; Démarrer le timer pour surveiller la position de la fenêtre
        ; Cela permet de mettre à jour state.guiX et state.guiY même si l'utilisateur
        ; déplace la fenêtre sans utiliser le drag and drop (par exemple avec Win+flèches)
        SetTimer(MonitorWindowPosition, 500)  ; Vérifier toutes les 500ms

        ; Monitor reading status
        SetTimer(CheckReadingStatus, 100)
    } catch as err {
        MsgBox "Error using text-to-speech: " . err.Message
        ResetState()
    }
}

CheckReadingStatus() {
    if (voice.Status.RunningState == 1) { ; If reading is complete
        ; Vérifier s'il y a d'autres paragraphes à lire
        if (state.currentParagraphIndex < state.paragraphs.Length) {
            ; Passer au paragraphe suivant
            state.currentParagraphIndex++

            ; Récupérer le texte du paragraphe suivant
            nextParagraphText := state.paragraphs[state.currentParagraphIndex]

            if (nextParagraphText != "") {
                ; Update current text and start new reading
                state.currentText := nextParagraphText
                voice.Rate := state.internalRate
                voice.Volume := state.volume
                voice.Speak(nextParagraphText, 1)  ; Start new asynchronous reading
                return
            }
        }

        ; Si nous sommes arrivés ici, c'est qu'il n'y a plus de paragraphes à lire
        StopReading()
        SetTimer(CheckReadingStatus, 0) ; Stop the timer
    }
}

ResetState() {
    state.isReading := false
    state.isPaused := false
    state.paragraphs := []
    state.currentParagraphIndex := 0
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

    ; Arrêter le timer de surveillance de la position
    SetTimer(MonitorWindowPosition, 0)

    ; Close the settings GUI if it's open
    if (state.settingsGuiVisible) {
        CloseSettingsGui()
    }

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

; Create and show the control interface GUI
; CreateControlGui est maintenant défini dans UIManager.ahk

; Variables for GUI dragging and position tracking
; dragState est maintenant défini dans UIManager.ahk

; Function to handle GUI dragging
; GuiDragHandler est maintenant défini dans UIManager.ahk

; Function to handle GUI dragging movement
; GuiDragMoveHandler est maintenant défini dans UIManager.ahk

; Function to handle GUI drag release
; GuiDragReleaseHandler est maintenant défini dans UIManager.ahk

; Function to monitor window position and update state
; MonitorWindowPosition est maintenant défini dans UIManager.ahk

; CloseControlGui est maintenant défini dans UIManager.ahk

; UpdateControlGui est maintenant défini dans UIManager.ahk

; ToggleSettingsGui est maintenant défini dans UIManager.ahk

; CreateSettingsGui est maintenant défini dans UIManager.ahk

; UpdateSettingsValues est maintenant défini dans UIManager.ahk

; CloseSettingsGui est maintenant défini dans UIManager.ahk
