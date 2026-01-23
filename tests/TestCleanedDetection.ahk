#Requires AutoHotkey v2.0
#Include "../src/TextProcessor.ahk"

; Test de la détection nettoyée (sans duplication)

OutputDebug("=== Test de la détection nettoyée ===")

; Tests avec accents (doivent être détectés en priorité)
accentTests := [
    {text: "café", expected: "FR"},
    {text: "système", expected: "FR"},
    {text: "être", expected: "FR"},
    {text: "The café is open", expected: "FR"}
]

OutputDebug("Tests avec accents (priorité absolue):")
for test in accentTests {
    result := DetectLanguage(test.text)
    hasPriority := HasFrenchPriorityIndicators(test.text)
    status := (result == test.expected) ? "✓" : "✗"
    OutputDebug("  " . status . " '" . test.text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests avec mots français SANS accents (doivent être détectés en priorité)
wordTests := [
    {text: "le système", expected: "FR"},
    {text: "dans la maison", expected: "FR"},
    {text: "avec les amis", expected: "FR"},
    {text: "pour tous", expected: "FR"},
    {text: "chez moi", expected: "FR"},
    {text: "donc nous", expected: "FR"}
]

OutputDebug("Tests avec mots français sans accents (priorité absolue):")
for test in wordTests {
    result := DetectLanguage(test.text)
    hasPriority := HasFrenchPriorityIndicators(test.text)
    status := (result == test.expected) ? "✓" : "✗"
    OutputDebug("  " . status . " '" . test.text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests avec contractions françaises (doivent être détectés en priorité)
contractionTests := [
    {text: "qu'il fait", expected: "FR"},
    {text: "l'eau", expected: "FR"},
    {text: "d'accord", expected: "FR"},
    {text: "n'est pas", expected: "FR"},
    {text: "c'est bon", expected: "FR"}
]

OutputDebug("Tests avec contractions (priorité absolue):")
for test in contractionTests {
    result := DetectLanguage(test.text)
    hasPriority := HasFrenchPriorityIndicators(test.text)
    status := (result == test.expected) ? "✓" : "✗"
    OutputDebug("  " . status . " '" . test.text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests anglais purs (pas de priorité française)
englishTests := [
    {text: "Hello world", expected: "EN"},
    {text: "This is a test", expected: "EN"},
    {text: "The system is working", expected: "EN"}
]

OutputDebug("Tests anglais purs (pas de priorité):")
for test in englishTests {
    result := DetectLanguage(test.text)
    hasPriority := HasFrenchPriorityIndicators(test.text)
    status := (result == test.expected) ? "✓" : "✗"
    OutputDebug("  " . status . " '" . test.text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests mixtes (priorité française attendue)
mixedTests := [
    {text: "Programming dans Python", expected: "FR"},
    {text: "The système works", expected: "FR"},
    {text: "Error: l'utilisateur not found", expected: "FR"}
]

OutputDebug("Tests mixtes (priorité française attendue):")
for test in mixedTests {
    result := DetectLanguage(test.text)
    hasPriority := HasFrenchPriorityIndicators(test.text)
    status := (result == test.expected) ? "✓" : "✗"
    OutputDebug("  " . status . " '" . test.text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

OutputDebug("=== Fin des tests ===")

MsgBox("Tests terminés! Vérifiez la console de débogage (DebugView) pour les résultats.", "Test de détection nettoyée")