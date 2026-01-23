#Requires AutoHotkey v2.0
#Include "../src/TextProcessor.ahk"

; Test de gestion des chemins de fichiers

testPaths := [
    "C:\Users\Username\Desktop\fichier.txt",
    "C:\Program Files\Application\file.exe",
    "D:\Documents\Projet\code.ahk",
    "C:\Windows\System32\notepad.exe"
]

OutputDebug("=== Test de gestion des chemins de fichiers ===")

for path in testPaths {
    ; Simuler le traitement
    processedText := IgnoreCharacters(path)
    paragraphs := SplitIntoParagraphs(processedText)
    
    OutputDebug("Chemin original: " . path)
    OutputDebug("  Après IgnoreCharacters: '" . processedText . "'")
    OutputDebug("  Nombre de paragraphes: " . paragraphs.Length)
    
    if (paragraphs.Length > 0) {
        OutputDebug("  Premier paragraphe: '" . paragraphs[1] . "'")
    } else {
        OutputDebug("  ✓ Aucun paragraphe (comportement attendu)")
    }
    OutputDebug("")
}

; Test avec du texte normal
normalText := "Ceci est un texte normal à lire"
processedNormal := IgnoreCharacters(normalText)
paragraphsNormal := SplitIntoParagraphs(processedNormal)

OutputDebug("Texte normal: " . normalText)
OutputDebug("  Après IgnoreCharacters: '" . processedNormal . "'")
OutputDebug("  Nombre de paragraphes: " . paragraphsNormal.Length)
if (paragraphsNormal.Length > 0) {
    OutputDebug("  ✓ Premier paragraphe: '" . paragraphsNormal[1] . "'")
}

OutputDebug("=== Fin des tests ===")

MsgBox("Tests terminés! Vérifiez la console de débogage pour les résultats.", "Test Chemins de Fichiers")