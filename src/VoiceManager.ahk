#Requires AutoHotkey v2.0

; Module for managing voice selection and detection

; Constants for settings file
global SETTINGS_FILE := A_ScriptDir . "\settingsTTS.ini"
global SETTINGS_SECTION := "VoiceSettings"

; Function to get available voices by language
GetAvailableVoices() {
    global voice

    voices := {
        EN: [],
        FR: []
    }

    ; Language codes mapping
    langMap := Map(
        "409", "EN",  ; English (US)
        "809", "EN",  ; English (UK)
        "40C", "FR",  ; French (FR)
        "C0C", "FR"   ; French (CA)
    )

    ; Temporary storage for filtering duplicates
    tempVoices := {
        EN: Map(),
        FR: Map()
    }

    try {
        for v in voice.GetVoices() {
            voiceName := ""
            voiceLang := ""

            try {
                voiceName := v.GetAttribute("Name")
                voiceLang := v.GetAttribute("Language")
            } catch {
                continue  ; Skip voices without proper attributes
            }

            ; Map language code to our language categories
            if (langMap.Has(voiceLang)) {
                targetLang := langMap[voiceLang]

                ; Extract base voice name (remove Desktop suffix if present)
                baseName := voiceName
                isDesktop := false

                if (InStr(voiceName, " Desktop")) {
                    baseName := StrReplace(voiceName, " Desktop", "")
                    isDesktop := true
                }

                ; Store voice, preferring Desktop versions
                if (!tempVoices.%targetLang%.Has(baseName) || isDesktop) {
                    tempVoices.%targetLang%[baseName] := voiceName
                }
            }
        }

        ; Convert maps to arrays
        for baseName, fullName in tempVoices.EN {
            voices.EN.Push(fullName)
        }
        for baseName, fullName in tempVoices.FR {
            voices.FR.Push(fullName)
        }

    } catch as err {
        OutputDebug("Error getting voices: " . err.Message)
    }

    return voices
}

; Function to get voice display name (remove "Microsoft " prefix if present)
GetVoiceDisplayName(voiceName) {
    if (InStr(voiceName, "Microsoft ") == 1) {
        return SubStr(voiceName, 11)  ; Remove "Microsoft " prefix
    }
    return voiceName
}

; Function to get full voice name (add "Microsoft " prefix if needed)
GetFullVoiceName(displayName) {
    if (InStr(displayName, "Microsoft ") != 1) {
        return "Microsoft " . displayName
    }
    return displayName
}

; Function to save voice settings to INI file
SaveVoiceSettings() {
    global state, SETTINGS_FILE, SETTINGS_SECTION

    ; Create directory if it doesn't exist
    SplitPath(SETTINGS_FILE, , &dir)
    if (!DirExist(dir))
        DirCreate(dir)

    ; Save voice selections
    IniWrite(state.selectedVoiceEN, SETTINGS_FILE, SETTINGS_SECTION, "SelectedVoiceEN")
    IniWrite(state.selectedVoiceFR, SETTINGS_FILE, SETTINGS_SECTION, "SelectedVoiceFR")
    IniWrite(state.languageMode, SETTINGS_FILE, SETTINGS_SECTION, "LanguageMode")

    ; Save other persistent settings if needed
    IniWrite(state.speed, SETTINGS_FILE, SETTINGS_SECTION, "Speed")
    IniWrite(state.volume, SETTINGS_FILE, SETTINGS_SECTION, "Volume")

    OutputDebug("Voice settings saved to " . SETTINGS_FILE)
}

; Function to load voice settings from INI file
LoadVoiceSettings() {
    global state, SETTINGS_FILE, SETTINGS_SECTION

    ; Check if settings file exists
    if (!FileExist(SETTINGS_FILE)) {
        OutputDebug("Settings file not found, using defaults")
        return
    }

    ; Load voice selections with defaults if not found
    state.selectedVoiceEN := IniRead(SETTINGS_FILE, SETTINGS_SECTION, "SelectedVoiceEN", state.selectedVoiceEN)
    state.selectedVoiceFR := IniRead(SETTINGS_FILE, SETTINGS_SECTION, "SelectedVoiceFR", state.selectedVoiceFR)
    state.languageMode := IniRead(SETTINGS_FILE, SETTINGS_SECTION, "LanguageMode", state.languageMode)

    ; Load other persistent settings
    state.speed := Number(IniRead(SETTINGS_FILE, SETTINGS_SECTION, "Speed", state.speed))
    state.volume := Number(IniRead(SETTINGS_FILE, SETTINGS_SECTION, "Volume", state.volume))

    ; Update internal rate based on loaded speed
    state.internalRate := Round(state.speed)

    OutputDebug("Voice settings loaded from " . SETTINGS_FILE)
}
