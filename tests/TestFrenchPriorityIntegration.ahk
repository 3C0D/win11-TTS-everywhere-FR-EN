#Requires AutoHotkey v2.0
#Include "../src/TextProcessor.ahk"

; Test d'intégration de la détection prioritaire française
; Ce test vérifie que les améliorations fonctionnent correctement

OutputDebug("=== Test d'intégration de la détection prioritaire française ===")

; Tests avec caractères accentués français
accentTests := [
    "café",
    "hôtel", 
    "être",
    "où",
    "français",
    "naïf",
    "Noël"
]

OutputDebug("Tests avec caractères accentués:")
for text in accentTests {
    result := DetectLanguage(text)
    hasPriority := HasFrenchPriorityIndicators(text)
    OutputDebug("  '" . text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests avec mots français garantis
wordTests := [
    "le système",
    "la programmation", 
    "les données",
    "du code",
    "très important",
    "beaucoup de travail",
    "voilà le résultat"
]

OutputDebug("Tests avec mots français garantis:")
for text in wordTests {
    result := DetectLanguage(text)
    hasPriority := HasFrenchPriorityIndicators(text)
    OutputDebug("  '" . text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests avec contractions françaises
contractionTests := [
    "qu'il fait",
    "l'eau est",
    "d'abord nous",
    "n'est pas",
    "c'est vrai",
    "j'ai dit"
]

OutputDebug("Tests avec contractions françaises:")
for text in contractionTests {
    result := DetectLanguage(text)
    hasPriority := HasFrenchPriorityIndicators(text)
    OutputDebug("  '" . text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests avec contenu mixte (priorité française attendue)
mixedTests := [
    "The système is working",
    "Programming avec les données",
    "Error: l'utilisateur n'est pas connecté",
    "SELECT * FROM table WHERE name = 'café'",
    "console.log('qu\\'il fait beau');"
]

OutputDebug("Tests avec contenu mixte (priorité française attendue):")
for text in mixedTests {
    result := DetectLanguage(text)
    hasPriority := HasFrenchPriorityIndicators(text)
    OutputDebug("  '" . text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

; Tests de contrôle (anglais pur, sans priorité française)
englishTests := [
    "Hello world",
    "This is a test",
    "The system is working",
    "Programming with data",
    "function getName() { return 'test'; }"
]

OutputDebug("Tests de contrôle (anglais pur):")
for text in englishTests {
    result := DetectLanguage(text)
    hasPriority := HasFrenchPriorityIndicators(text)
    OutputDebug("  '" . text . "' -> " . result . " (priorité: " . (hasPriority ? "OUI" : "NON") . ")")
}

OutputDebug("=== Fin des tests d'intégration ===")

MsgBox("Tests d'intégration terminés! Vérifiez la console de débogage pour les résultats détaillés.", "Test d'intégration")