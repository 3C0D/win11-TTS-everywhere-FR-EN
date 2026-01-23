#Requires AutoHotkey v2.0
#Include "../src/TextProcessor.ahk"

; Démonstration finale de la détection prioritaire française

testCases := [
    ; Accents français (priorité absolue)
    {text: "café", desc: "Accent français"},
    {text: "système", desc: "Accent français"},
    
    ; Mots français SANS accents (priorité absolue)
    {text: "le code", desc: "Article français 'le'"},
    {text: "dans la maison", desc: "Préposition 'dans' + article 'la'"},
    {text: "avec les amis", desc: "Préposition 'avec' + article 'les'"},
    {text: "chez moi", desc: "Préposition 'chez'"},
    {text: "donc nous", desc: "Conjonction 'donc'"},
    
    ; Contractions françaises (priorité absolue)
    {text: "qu'il fait", desc: "Contraction qu'il"},
    {text: "l'eau", desc: "Contraction l'"},
    {text: "c'est bon", desc: "Expression c'est"},
    
    ; Mixte (priorité française)
    {text: "The système works", desc: "Mixte avec accent"},
    {text: "Programming dans Python", desc: "Mixte avec mot français"},
    
    ; Anglais pur (pas de priorité)
    {text: "Hello world", desc: "Anglais pur"},
    {text: "This is a test", desc: "Anglais pur"}
]

results := "RÉSULTATS DE LA DÉTECTION PRIORITAIRE FRANÇAISE`n"
results .= "================================================`n`n"

for test in testCases {
    result := DetectLanguage(test.text)
    hasPriority := HasFrenchPriorityIndicators(test.text)
    priorityText := hasPriority ? "PRIORITÉ FR" : "Scoring normal"
    
    results .= test.desc . ":`n"
    results .= "  Texte: '" . test.text . "'`n"
    results .= "  Détection: " . result . " (" . priorityText . ")`n`n"
    
    OutputDebug(test.desc . ": '" . test.text . "' -> " . result . " (" . priorityText . ")")
}

MsgBox(results, "Démonstration Détection Française", "T30")  ; Auto-close après 30 secondes