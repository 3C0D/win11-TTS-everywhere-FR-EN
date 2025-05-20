#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "VoiceInitializer.ahk"
#Include "TextProcessor.ahk"
#Include "HotkeyManager.ahk"
#Include "UIManager.ahk"
#Include "SystrayManager.ahk"
#Include "StartupManager.ahk"

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

InitializeSystray()

; Initialize all hotkeys
InitializeHotkeys()
; Disable hotkeys at start
UpdateHotkeys(false)

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
