#Requires AutoHotkey v2.0

; Création de l'interface
MyGui := Gui()
MyGui.Opt("+Resize")
MyGui.Title := "Diagnostic des voix SAPI"

; Onglets pour organiser l'information
Tabs := MyGui.Add("Tab3", "w600 h400", ["Voix disponibles", "Registre", "Test de voix", "Diagnostic"])

; Onglet 1: Voix disponibles
Tabs.UseTab(1)
MyGui.Add("Text", "w580", "Voix SAPI détectées sur le système:")
VoiceListBox := MyGui.Add("ListView", "r10 w580 Grid", ["Nom", "ID", "Langue", "Âge", "Genre", "Chemin"])

; Récupération et affichage des voix
voices := ComObject("SAPI.SpVoice").GetVoices()
voiceList := ""

for v in voices {
    name := TryGetAttribute(v, "Name", "Inconnu")
    lang := TryGetAttribute(v, "Language", "")
    langName := GetLanguageName(lang)
    gender := TryGetAttribute(v, "Gender", "")
    genderName := (gender = 1) ? "Femme" : ((gender = 2) ? "Homme" : "Inconnu")
    age := TryGetAttribute(v, "Age", "")
    path := TryGetAttribute(v, "Path", "")

    VoiceListBox.Add(, name, lang, langName, age, genderName, path)
    voiceList .= name . " (" . langName . ")`n"
}

; Onglet 2: Informations du registre
Tabs.UseTab(2)
MyGui.Add("Text", "w580", "Entrées de registre pour les voix SAPI:")
RegEdit := MyGui.Add("Edit", "r15 w580 ReadOnly")

; Récupération des informations du registre
regInfo := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices\Tokens\`n`n"
try {
    loop reg, "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices\Tokens", "K" {
        regInfo .= A_LoopRegName . "`n"
        try {
            voiceName := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices\Tokens\" A_LoopRegName, "")
            regInfo .= "  → " . voiceName . "`n"
        }
    }
} catch as e {
    regInfo .= "; Error reading registry: " . e.Message . "`n"
}

RegEdit.Text := regInfo

; Onglet 3: Test de voix
Tabs.UseTab(3)
MyGui.Add("Text", "w580", "; Select a voice and test it:")
VoiceCombo := MyGui.Add("ComboBox", "w580 vSelectedVoice")

; Remplir la liste déroulante avec les voix disponibles
for v in voices {
    voiceName := TryGetAttribute(v, "Name", "Voix sans nom")
    VoiceCombo.Add([voiceName])
}
VoiceCombo.Choose(1)

TestText := MyGui.Add("Edit", "r5 w580 vTestText",
    "Ceci est un test de synthèse vocale. This is a text-to-speech test.")
TestButton := MyGui.Add("Button", "w200", "Tester la voix")
TestButton.OnEvent("Click", TestSelectedVoice)

; Ajout d'un nouvel onglet pour le diagnostic
Tabs.UseTab(4)
MyGui.Add("Text", "w580", "Diagnostic des voix manquantes:")
DiagnosticEdit := MyGui.Add("Edit", "r10 w580 ReadOnly vDiagnosticInfo")
ScanButton := MyGui.Add("Button", "w200", "Scanner les voix manquantes")
ScanButton.OnEvent("Click", ScanMissingVoices)
RegisterButton := MyGui.Add("Button", "w200 y+10", "Tenter de réenregistrer les voix")
RegisterButton.OnEvent("Click", AttemptToRegisterVoices)

; Boutons communs à tous les onglets
Tabs.UseTab()
CopyButton := MyGui.Add("Button", "w200 x10 y+20", "Copier les informations")
CopyButton.OnEvent("Click", CopyAllInfo)

MyGui.Add("Button", "Default w200 x+20", "Fermer").OnEvent("Click", (*) => MyGui.Destroy())

MyGui.OnEvent("Close", (*) => MyGui.Destroy())
MyGui.OnEvent("Escape", (*) => MyGui.Destroy())

MyGui.Show()

; Fonctions
CopyAllInfo(*) {
    global MyGui, voiceList, regInfo, Tabs

    ; Récupérer l'onglet actif pour adapter le contenu copié
    activeTab := Tabs.Value

    fullInfo := ""

    if (activeTab = 1 || activeTab = 0) {
        fullInfo .= "=== VOIX DISPONIBLES ===`n" . voiceList . "`n`n"
    }

    if (activeTab = 2 || activeTab = 0) {
        fullInfo .= "=== INFORMATIONS DU REGISTRE ===`n" . regInfo . "`n`n"
    }

    if (activeTab = 4) {
        fullInfo .= "=== DIAGNOSTIC ===`n" . MyGui["DiagnosticInfo"].Text . "`n`n"
    }

    if (fullInfo = "") {
        fullInfo := "; No information to copy in this tab."
    }

    A_Clipboard := fullInfo
    MsgBox("; Information copied to clipboard!")
}

ScanMissingVoices(*) {
    global MyGui

    diagnosticInfo := "; Searching for voice files in Windows...`n`n"

    ; Chemins possibles pour les fichiers de voix (liste étendue)
    voicePaths := [
        "C:\Windows\Speech\Engines\TTS\",
        "C:\Windows\Speech_OneCore\Engines\TTS\",
        "C:\Program Files\Common Files\Microsoft Shared\Speech\",
        "C:\Windows\SysWOW64\Speech\Engines\TTS\",
        "C:\Windows\System32\Speech\Engines\TTS\",
        "C:\Windows\SysWOW64\Speech_OneCore\Engines\TTS\",
        "C:\Windows\System32\Speech_OneCore\Engines\TTS\"
    ]

    foundVoiceFiles := []

    ; Rechercher les fichiers de voix
    for path in voicePaths {
        if DirExist(path) {
            diagnosticInfo .= "Vérification du dossier: " . path . "`n"

            try {
                loop files, path . "*.dll" {
                    if InStr(A_LoopFileName, "TTS") || InStr(A_LoopFileName, "Speech") {
                        foundVoiceFiles.Push(A_LoopFilePath)
                        diagnosticInfo .= "; Found: " . A_LoopFileName . "`n"
                    }
                }
            } catch as e {
                diagnosticInfo .= "; Error: " . e.Message . "`n"
            }
        } else {
            diagnosticInfo .= "Dossier non trouvé: " . path . "`n"
        }
    }

    ; Recherche supplémentaire dans les dossiers Windows
    diagnosticInfo .= "`n; Deep search in system folders...`n"

    systemPaths := [
        "C:\Windows\System32\",
        "C:\Windows\SysWOW64\"
    ]

    for path in systemPaths {
        if DirExist(path) {
            diagnosticInfo .= "Vérification du dossier: " . path . "`n"

            try {
                loop files, path . "*speech*.dll" {
                    foundVoiceFiles.Push(A_LoopFilePath)
                    diagnosticInfo .= "; Found: " . A_LoopFileName . "`n"
                }

                loop files, path . "*tts*.dll" {
                    foundVoiceFiles.Push(A_LoopFilePath)
                    diagnosticInfo .= "; Found: " . A_LoopFileName . "`n"
                }
            } catch as e {
                diagnosticInfo .= "; Error: " . e.Message . "`n"
            }
        }
    }

    ; Comparer avec les voix enregistrées
    diagnosticInfo .= "`n; Comparison with registered voices...`n"
    registeredVoices := []

    try {
        loop reg, "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech\Voices\Tokens", "K" {
            registeredVoices.Push(A_LoopRegName)
        }
    } catch as e {
        diagnosticInfo .= "; Error reading registry: " . e.Message . "`n"
    }

    diagnosticInfo .= "`nRésumé:`n"
    diagnosticInfo .= "- Fichiers de voix trouvés: " . foundVoiceFiles.Length . "`n"
    diagnosticInfo .= "- Voix enregistrées: " . registeredVoices.Length . "`n"

    ; Vérification des clés de registre supplémentaires
    diagnosticInfo .= "`nVérification des clés de registre alternatives...`n"

    alternativeRegPaths := [
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens",
        "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Speech\Voices\Tokens",
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech Server\v11.0\Voices"
    ]

    for regPath in alternativeRegPaths {
        diagnosticInfo .= "Vérification de: " . regPath . "`n"

        try {
            count := 0
            loop reg, regPath, "K" {
                count++
                diagnosticInfo .= "; Found: " . A_LoopRegName . "`n"
            }

            if (count = 0) {
                diagnosticInfo .= "  Aucune entrée trouvée.`n"
            } else {
                diagnosticInfo .= "  " . count . " entrées trouvées.`n"
            }
        } catch as e {
            diagnosticInfo .= "  Erreur ou chemin non trouvé: " . e.Message . "`n"
        }
    }

    ; Recommandations
    diagnosticInfo .= "`nRecommandations:`n"

    if (foundVoiceFiles.Length = 0) {
        diagnosticInfo .=
            "- Les fichiers de voix semblent manquants. Essayez de réinstaller les packs de voix depuis les paramètres Windows.`n"
        diagnosticInfo .=
            "- Allez dans Paramètres > Temps et langue > Langue et région > [votre langue] > Options > Synthèse vocale`n"
    } else if (registeredVoices.Length < 4) {
        diagnosticInfo .=
            "- Certaines voix sont présentes mais pas correctement enregistrées. Utilisez le bouton 'Tenter de réenregistrer les voix'.`n"
        diagnosticInfo .=
            "- Vous pouvez aussi essayer d'installer des voix supplémentaires depuis les paramètres Windows.`n"
    }

    MyGui["DiagnosticInfo"].Text := diagnosticInfo
}

AttemptToRegisterVoices(*) {
    global MyGui

    diagnosticInfo := "Tentative de réenregistrement des voix...`n`n"

    ; Commandes pour réenregistrer les voix (liste étendue)
    commands := [
        "regsvr32 /s C:\Windows\Speech\Engines\TTS\*.dll",
        "regsvr32 /s C:\Windows\Speech_OneCore\Engines\TTS\*.dll",
        "regsvr32 /s C:\Windows\System32\Speech\Engines\TTS\*.dll",
        "regsvr32 /s C:\Windows\SysWOW64\Speech\Engines\TTS\*.dll",
        "regsvr32 /s C:\Windows\System32\Speech_OneCore\Engines\TTS\*.dll",
        "regsvr32 /s C:\Windows\SysWOW64\Speech_OneCore\Engines\TTS\*.dll",
        "regsvr32 /s C:\Windows\System32\speech*.dll",
        "regsvr32 /s C:\Windows\SysWOW64\speech*.dll"
    ]

    for cmd in commands {
        diagnosticInfo .= "Exécution de: " . cmd . "`n"

        try {
            RunWait(A_ComSpec . " /c " . cmd, , "Hide")
            diagnosticInfo .= "  Commande exécutée avec succès.`n"
        } catch as e {
            diagnosticInfo .= "; Error: " . e.Message . "`n"
        }
    }

    ; Tentative de réparation des services liés à la synthèse vocale
    diagnosticInfo .= "`nTentative de réparation des services de synthèse vocale...`n"

    services := [
        "sppsvc",        ; Service de protection des plateformes
        "Audiosrv",      ; Service audio Windows
        "AudioEndpointBuilder", ; Générateur de points de terminaison audio Windows
        "SpeechService"  ; Service de reconnaissance vocale et synthèse vocale
    ]

    for service in services {
        diagnosticInfo .= "Redémarrage du service: " . service . "`n"

        try {
            RunWait(A_ComSpec . " /c net stop " . service . " && net start " . service, , "Hide")
            diagnosticInfo .= "  Service redémarré avec succès.`n"
        } catch as e {
            diagnosticInfo .= "  Erreur ou service non trouvé: " . e.Message . "`n"
        }
    }

    ; Vérification des paramètres de langue
    diagnosticInfo .= "`nVérification des paramètres de langue...`n"
    diagnosticInfo .= "- Assurez-vous que les packs de langue sont correctement installés.`n"
    diagnosticInfo .= "- Vous pouvez ouvrir les paramètres de langue avec la commande suivante:`n"
    diagnosticInfo .= "  ms-settings:regionlanguage`n"

    diagnosticInfo .=
        "`nOpération terminée. Veuillez redémarrer l'application pour vérifier si de nouvelles voix sont disponibles.`n"
    diagnosticInfo .=
        "Si le problème persiste, vous pourriez avoir besoin de réinstaller les packs de voix depuis les paramètres Windows.`n"

    MyGui["DiagnosticInfo"].Text := diagnosticInfo
}

TestSelectedVoice(*) {
    global MyGui, voices

    selectedIndex := MyGui["SelectedVoice"].Value
    testText := MyGui["TestText"].Text

    if (selectedIndex > 0 && testText != "") {
        try {
            voice := ComObject("SAPI.SpVoice")
            voice.Voice := voices[selectedIndex - 1]  ; -1 car les index ComboBox commencent à 1
            voice.Speak(testText)
        } catch as e {
            MsgBox("Erreur lors du test de la voix: " . e.Message)
        }
    } else {
        MsgBox("Veuillez sélectionner une voix et entrer du texte à tester.")
    }
}

; Fonction pour obtenir le nom de la langue à partir du code
GetLanguageName(langID) {
    langMap := Map(
        "409", "Anglais (US)",
        "809", "Anglais (UK)",
        "40C", "Français (FR)",
        "C0C", "Français (CA)",
        "410", "Italien",
        "407", "Allemand",
        "40A", "Espagnol",
        "411", "Japonais"
    )

    return langMap.Has(langID) ? langMap[langID] : "Inconnu (" . langID . ")"
}

; Fonction pour obtenir un attribut de manière sécurisée
TryGetAttribute(voiceObj, attrName, defaultValue := "") {
    try {
        return voiceObj.GetAttribute(attrName)
    } catch {
        return defaultValue
    }
}
