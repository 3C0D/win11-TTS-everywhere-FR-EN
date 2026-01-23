#Requires AutoHotkey v2.0
#Include "../src/TextProcessor.ahk"

; Test rapide de la détection prioritaire du français
testCases := [
    "café",
    "hôtel", 
    "être",
    "où",
    "le système",
    "qu'il fait",
    "l'eau",
    "c'est vrai",
    "très important",
    "The café is open",
    "Programming avec les données"
]

results := []
for text in testCases {
    result := DetectLanguage(text)
    results.Push(text . " -> " . result)
    OutputDebug(text . " -> " . result)
}

; Afficher les résultats dans une MsgBox
resultText := ""
for result in results {
    resultText .= result . "`n"
}

MsgBox("Résultats des tests de détection prioritaire:`n`n" . resultText, "Test de détection française")