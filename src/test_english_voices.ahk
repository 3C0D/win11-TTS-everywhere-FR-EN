#Requires AutoHotkey v2.0

; Script simple pour tester Mark et David
voice := ComObject("SAPI.SpVoice")
voices := voice.GetVoices()

; Tester chaque voix anglaise
for v in voices {
    voiceName := ""
    try {
        voiceName := v.GetAttribute("Name")
    }
    
    if (InStr(voiceName, "Mark") || InStr(voiceName, "David") || InStr(voiceName, "Zira")) {
        MsgBox("Test de la voix: " . voiceName . "`n`nCliquez OK pour tester...")
        
        try {
            voice.Voice := v
            voice.Speak("Hello, this is a test of " . voiceName)
            MsgBox(voiceName . " fonctionne !")
        } catch as e {
            MsgBox(voiceName . " NE FONCTIONNE PAS`nErreur: " . e.Message)
        }
    }
}