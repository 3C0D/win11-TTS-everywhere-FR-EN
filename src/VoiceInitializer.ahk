#Requires AutoHotkey v2.0

; Module for voice initialization

/*
 * Initializes TTS voices by copying them from OneCore to standard registry locations
 * This ensures all available voices are accessible to the application
*/
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
            "Additional voices are available. The script will restart with administrator rights to install them."
        )
        try {
            ; Si l'application est compilée (format .exe distribué à l'utilisateur)
            if A_IsCompiled
                ; Relance l'application avec droits administrateur en remplaçant l'instance actuelle
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
            ; Version pour développement : lance l'interpréteur AutoHotkey avec le script
            ; Cette partie n'est jamais exécutée dans la version compilée
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            ; Termine l'instance actuelle pour éviter d'avoir des doublons dans la zone de notification
            ExitApp
        }
        catch {
            MsgBox("Unable to obtain administrator rights. Some voices may not be available.")
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

            MsgBox(voicesAdded " additional voices have been installed. The application will restart.")
            Reload
        } else {
            MsgBox("No new voices were installed.")
        }
    }
    catch as err {
        MsgBox("Error updating voices: " err.Message)
    }
}
