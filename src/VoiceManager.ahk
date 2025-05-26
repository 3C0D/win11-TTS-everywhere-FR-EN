#Requires AutoHotkey v2.0

; Module for managing voice selection and detection

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
