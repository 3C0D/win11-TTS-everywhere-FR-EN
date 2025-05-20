#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "VoiceInitializer.ahk"

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

; Function to jump to the next paragraph
JumpToNextLine(*) {
    ; Do nothing if reading is paused
    if (state.isPaused)
        return

    ; Vérifier si nous sommes déjà au dernier paragraphe
    if (state.currentParagraphIndex >= state.paragraphs.Length) {
        ; Nous sommes déjà au dernier paragraphe, ne rien faire
        return
    }

    ; Stop the current reading completely (necessary to reset SAPI state)
    voice.Speak("", 3)  ; SVSFPurgeBeforeSpeak (stops immediately)

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
    } else {
        StopReading()  ; If no more text, stop reading
    }
}

; pause/resume
#!y:: TogglePause()

; Function to jump to the previous paragraph
JumpToPreviousParagraph(*) {
    if (state.isPaused)
        return

    ; Vérifier si nous sommes déjà au premier paragraphe
    if (state.currentParagraphIndex <= 1) {
        ; Nous sommes déjà au premier paragraphe, redémarrer la lecture depuis le début
        state.currentParagraphIndex := 1

        ; Stop the current reading completely (necessary to reset SAPI state)
        voice.Speak("", 3)  ; SVSFPurgeBeforeSpeak (stops immediately)

        ; Récupérer le texte du premier paragraphe
        firstParagraphText := state.paragraphs[1]

        ; Update current text and start new reading
        state.currentText := firstParagraphText
        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(firstParagraphText, 1)  ; Start new asynchronous reading
        return
    }

    ; Stop the current reading completely (necessary to reset SAPI state)
    voice.Speak("", 3)  ; SVSFPurgeBeforeSpeak (stops immediately)

    ; Revenir au paragraphe précédent
    state.currentParagraphIndex--

    ; Récupérer le texte du paragraphe précédent
    prevParagraphText := state.paragraphs[state.currentParagraphIndex]

    if (prevParagraphText != "") {
        ; Update current text and start new reading
        state.currentText := prevParagraphText
        voice.Rate := state.internalRate
        voice.Volume := state.volume
        voice.Speak(prevParagraphText, 1)  ; Start new asynchronous reading
    } else {
        StopReading()
    }
}

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

; Fonction pour diviser le texte en paragraphes
SplitIntoParagraphs(text) {
    ; Méthode simple : considérer chaque ligne comme un paragraphe
    ; Cela garantit que le texte est lu ligne par ligne
    paragraphs := []

    ; Diviser le texte en lignes
    lines := StrSplit(text, "`n")

    ; Ajouter chaque ligne non vide comme un paragraphe
    for line in lines {
        ; Ignorer les lignes vides
        if (!RegExMatch(line, "^\s*$")) {
            paragraphs.Push(line)
        }
    }

    ; Si aucun paragraphe n'a été trouvé, ajouter le texte entier comme un seul paragraphe
    if (paragraphs.Length == 0 && text != "") {
        paragraphs.Push(text)
    }

    return paragraphs
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
    ; Ignore les caractères répétés plus de 4 fois
    text := RegExReplace(text, "(.)\1{4,}", "")

    ; Ignorer d'abord les adresses web (http://, https://, www.)
    ; Le ? après le s rend le s optionnel, donc cette règle capture http:// et https://
    text := RegExReplace(text, "https?://[^\s]+", "")
    ; Cette règle capture les URLs commençant par www.
    text := RegExReplace(text, "www\.[^\s]+", "")

    ; Ignorer les chemins de fichiers (contenant plusieurs slash ou antislash)
    text := RegExReplace(text, "[A-Za-z]:\\[^\s\\/:*?" "<>|]+(?:\\[^\s\\/:*?" "<>|]+)+", "")  ; Chemins Windows
    text := RegExReplace(text, "/(?:[^\s/]+/)+", "")  ; Chemins Unix/Linux

    ; Ignorer les doubles slash (//) mais conserver les slash simples (/)
    text := RegExReplace(text, "//", "")

    ; Remplacer les antislash isolés par le mot "backslash" pour que le moteur TTS les lise
    text := RegExReplace(text, "(?<!\S)\\(?!\S)", " backslash ")

    ; Remplacer les slash isolés par le mot "slash" pour que le moteur TTS les lise de façon cohérente
    text := RegExReplace(text, "(?<!\S)/(?!\S)", " slash ")

    ; Supprimer le dièse des hashtags (#mot) mais conserver le mot
    text := RegExReplace(text, "#(\w+)", "$1")

    ; Supprimer les dièses des titres markdown (# Titre, ## Titre, etc.) mais conserver le texte
    text := RegExReplace(text, "m)^#{1,6}\s+(.*?)$", "$1")  ; Le m) au début active le mode multiline

    ; Ignorer les caractères spécifiques restants
    charactersToIgnore := ["*", "@"]
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

    ; Make the GUI draggable without click-through style
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
    controlGui.Add("Button", "x15 y15 " . buttonOptions, "⏮").OnEvent("Click", (*) => JumpToPreviousParagraph())

    ; Play/Pause button
    global playPauseBtn  ; Make this global too
    playPauseBtn := controlGui.Add("Button", "x+10 y15 " . buttonOptions, state.isPaused ? "▶" : "⏸")
    playPauseBtn.OnEvent("Click", TogglePause)

    ; Stop button
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⏹").OnEvent("Click", (*) => CloseControlGui())

    ; Next paragraph button
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⏭").OnEvent("Click", (*) => JumpToNextLine())

    ; Settings button (gear icon)
    controlGui.Add("Button", "x+10 y15 " . buttonOptions, "⚙").OnEvent("Click", ToggleSettingsGui)

    ; Show the GUI
    controlGui.Show("x" . xPos . " y" . yPos . " w" . guiWidth . " h" . guiHeight . " NoActivate")
    state.controlGuiVisible := true

    return controlGui
}

; Variables for GUI dragging and position tracking
global dragState := {
    isMouseDown: false,
    initialX: 0,
    initialY: 0,
    initialWinX: 0,
    initialWinY: 0,
    lastSavedX: 0,  ; Dernière position X sauvegardée
    lastSavedY: 0   ; Dernière position Y sauvegardée
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

; Function to handle GUI drag release
GuiDragReleaseHandler(wParam, lParam, msg, hwnd) {
    global controlGui, dragState, state  ; Ensure we're using the global variables

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Stop dragging
    dragState.isMouseDown := false

    ; Save the current position of the window
    WinGetPos(&winX, &winY, , , "ahk_id " . controlGui.Hwnd)

    ; Mettre à jour la position dans l'objet state
    state.guiX := winX
    state.guiY := winY

    ; Afficher dans la console de débogage
    OutputDebug("Position mise à jour dans state: X=" winX ", Y=" winY)

    ; Remove handlers
    OnMessage(0x200, GuiDragMoveHandler, 0)  ; Remove WM_MOUSEMOVE handler
    OnMessage(0x202, GuiDragReleaseHandler, 0)  ; Remove WM_LBUTTONUP handler

    return 0
}

; Function to monitor window position and update state
MonitorWindowPosition() {
    global controlGui, settingsGui, dragState, state

    if (!controlGui || !state.controlGuiVisible)
        return

    ; Get current window position
    WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " . controlGui.Hwnd)

    ; Check if position has changed since last update
    if (winX != dragState.lastSavedX || winY != dragState.lastSavedY) {
        ; Update state with new position
        state.guiX := winX
        state.guiY := winY

        ; Update last saved position
        dragState.lastSavedX := winX
        dragState.lastSavedY := winY

        OutputDebug("Position mise à jour via timer: X=" winX ", Y=" winY)

        ; If settings GUI is open, move it to follow the main GUI
        if (settingsGui && state.settingsGuiVisible) {
            ; Calculate new position for settings GUI (below the main GUI)
            settingsX := winX
            settingsY := winY + winHeight

            ; Move the settings GUI
            WinMove(settingsX, settingsY, , , "ahk_id " . settingsGui.Hwnd)
        }
    }
}

; Function to close the control GUI
CloseControlGui(*) {
    global controlGui, dragState  ; Ensure we're using the global variables

    ; Remove any mouse message handlers
    OnMessage(0x201, GuiDragHandler, 0)  ; Remove WM_LBUTTONDOWN handler
    OnMessage(0x200, GuiDragMoveHandler, 0)  ; Remove WM_MOUSEMOVE handler
    OnMessage(0x202, GuiDragReleaseHandler, 0)  ; Remove WM_LBUTTONUP handler

    ; Arrêter le timer de surveillance de la position
    SetTimer(MonitorWindowPosition, 0)

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
    global speedTextCtrl, volumeTextCtrl

    ; Destroy existing GUI if it exists
    if (settingsGui) {
        settingsGui.Destroy()
    }

    ; Get position of the main control GUI
    WinGetPos(&controlX, &controlY, &controlWidth, &controlHeight, "ahk_id " . controlGui.Hwnd)

    ; Create a new GUI with a compact style
    settingsGui := Gui("+AlwaysOnTop +ToolWindow -Caption +Owner" . controlGui.Hwnd)
    settingsGui.SetFont("s10", "Segoe UI")

    ; Calculate position (below the main control GUI)
    settingsWidth := 240  ; Keep original width
    settingsHeight := 120
    settingsX := controlX
    settingsY := controlY + controlHeight

    ; Add controls for speed adjustment
    settingsGui.Add("Text", "x10 y10 w60", "Vitesse:")
    settingsGui.Add("Button", "x+5 y8 w30 h25", "-").OnEvent("Click", (*) => AdjustSpeedDown())
    speedTextCtrl := settingsGui.Add("Text", "x+5 y10 w30 Center", Format("{:.1f}", state.speed))
    settingsGui.Add("Button", "x+5 y8 w30 h25", "+").OnEvent("Click", (*) => AdjustSpeedUp())
    settingsGui.Add("Text", "x+5 y10 w30", "Num±")

    ; Add controls for volume adjustment
    settingsGui.Add("Text", "x10 y45 w60", "Volume:")
    settingsGui.Add("Button", "x+5 y43 w30 h25", "-").OnEvent("Click", (*) => VolumeDown())
    volumeTextCtrl := settingsGui.Add("Text", "x+5 y45 w30 Center", state.volume . "%")
    settingsGui.Add("Button", "x+5 y43 w30 h25", "+").OnEvent("Click", (*) => VolumeUp())
    settingsGui.Add("Text", "x+5 y45 w30", "Num*/")

    ; Add info text
    settingsGui.Add("Text", "x10 y80 w220 Center", "Cliquez sur ⚙ pour fermer")

    ; Show the GUI
    settingsGui.Show("x" . settingsX . " y" . settingsY . " w" . settingsWidth . " h" . settingsHeight . " NoActivate")
    state.settingsGuiVisible := true

    ; Update the settings values every 100ms
    SetTimer(UpdateSettingsValues, 100)

    return settingsGui
}

; Function to update the settings values in real-time
UpdateSettingsValues() {
    global settingsGui, speedTextCtrl, volumeTextCtrl

    if (!settingsGui || !state.settingsGuiVisible)
        return

    try {
        ; Mettre à jour les valeurs directement
        if (speedTextCtrl) {
            speedTextCtrl.Text := Format("{:.1f}", state.speed)
        }

        if (volumeTextCtrl) {
            volumeTextCtrl.Text := state.volume . "%"
        }
    } catch as err {
        OutputDebug("Error updating settings GUI: " . err.Message)
        SetTimer(UpdateSettingsValues, 0)  ; Stop the timer if there's an error
    }
}

; Function to close the settings GUI
CloseSettingsGui(*) {
    global settingsGui, speedTextCtrl, volumeTextCtrl

    ; Stop the update timer
    SetTimer(UpdateSettingsValues, 0)

    if (settingsGui) {
        settingsGui.Destroy()
        settingsGui := false
        speedTextCtrl := false
        volumeTextCtrl := false
        state.settingsGuiVisible := false
    }
}
