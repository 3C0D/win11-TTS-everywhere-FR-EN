#Requires AutoHotkey v2.0

; Functions for text processing and language detection

; Fonction pour diviser le texte en paragraphes
SplitIntoParagraphs(text) {
    ; Méthode simple : considérer chaque ligne comme un paragraphe
    ; Cela garantit que le texte est lu ligne par ligne
    paragraphs := []

    ; Diviser le texte en lignes
    lines := StrSplit(text, "`n")

    ; Ajouter chaque ligne non vide comme un paragraphe
    for line in lines {
        ; Ignorer les lignes vides
        if (!RegExMatch(line, "^\s*$")) {
            paragraphs.Push(line)
        }
    }

    ; Si aucun paragraphe n'a été trouvé, ajouter le texte entier comme un seul paragraphe
    if (paragraphs.Length == 0 && text != "") {
        paragraphs.Push(text)
    }

    return paragraphs
}

DetectLanguage(text) {
    ; Language detection based on common words and patterns
    frenchWords := ["le", "la", "les", "un", "une", "des", "et", "ou", "mais", "donc", "or", "ni", "car", "que", "qui",
        "quoi", "dont", "où", "à", "au", "avec", "pour", "sur", "dans", "par", "ce", "cette", "ces", "je", "tu", "il",
        "elle",
        "nous", "vous", "ils", "elles", "mon", "ton", "son", "notre", "votre", "leur"
    ]
    englishWords := ["the", "and", "or", "but", "so", "yet", "for", "nor", "that", "which", "who", "whom", "whose",
        "when", "where", "why", "how", "a", "an", "in", "on", "at", "with", "by", "this", "these", "those", "is", "are",
        "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "shall",
        "should"
    ]

    ; Add weight to more distinctive words
    distinctiveFrench := ["est", "sont", "être", "avoir", "fait", "très", "beaucoup", "toujours", "jamais"]
    distinctiveEnglish := ["is", "are", "be", "have", "do", "very", "much", "always", "never"]

    frenchScore := 0
    englishScore := 0

    ; Count French-specific characters (adds to French score)
    frenchChars := "éèêëàâäôöùûüçÉÈÊËÀÂÄÔÖÙÛÜÇ"
    for char in StrSplit(text) {
        if InStr(frenchChars, char)
            frenchScore += 0.5  ; Give moderate weight to accented characters
    }

    ; Split text into words, normalize to lowercase for accurate counting
    words := StrSplit(StrLower(text), " ")
    for word in words {
        ; Check regular words
        if (HasVal(frenchWords, word))
            frenchScore++
        if (HasVal(englishWords, word))
            englishScore++

        ; Give extra weight to distinctive words
        if (HasVal(distinctiveFrench, word))
            frenchScore += 2
        if (HasVal(distinctiveEnglish, word))
            englishScore += 2
    }

    ; Check for language-specific patterns
    if (RegExMatch(text, "i)qu'[aeiouy]|c'est|n'[aeiouy]|l'[aeiouy]|d'[aeiouy]"))
        frenchScore += 3
    if (RegExMatch(text, "i)ing\s|ed\s|'s\s|'ve\s|'re\s|'ll\s"))
        englishScore += 3

    ; Determine the language based on score
    if (englishScore > frenchScore) {
        return "EN"
    } else {
        return "FR" ; Defaults to French if scores are equal or French is higher
    }
}

HasVal(haystack, needle) {
    ; Checks if a list contains a specific word
    for index, value in haystack
        if (value = needle)
            return true
    return false
}

IgnoreCharacters(text) {
    ; Ignore les caractères répétés plus de 4 fois
    text := RegExReplace(text, "(.)\1{4,}", "")

    ; Ignorer d'abord les adresses web (http://, https://, www.)
    ; Le ? après le s rend le s optionnel, donc cette règle capture http:// et https://
    text := RegExReplace(text, "https?://[^\s]+", "")
    ; Cette règle capture les URLs commençant par www.
    text := RegExReplace(text, "www\.[^\s]+", "")

    ; Ignorer les chemins de fichiers (contenant plusieurs slash ou antislash)
    text := RegExReplace(text, "[A-Za-z]:\\[^\s\\/:*?" "<>|]+(?:\\[^\s\\/:*?" "<>|]+)+", "")  ; Chemins Windows
    text := RegExReplace(text, "/(?:[^\s/]+/)+", "")  ; Chemins Unix/Linux
    
    ; Ignorer les doubles slash (//) mais conserver les slash simples (/)
    text := RegExReplace(text, "//", "")
    ; Remplacer les antislash isolés par le mot "backslash" pour que le moteur TTS les lise
    text := RegExReplace(text, "(?<!\S)\\(?!\S)", " backslash ")
    ; Remplacer les slash isolés par le mot "slash" pour que le moteur TTS les lise de façon cohérente
    text := RegExReplace(text, "(?<!\S)/(?!\S)", " slash ")
    ; Supprimer le dièse des hashtags (#mot) mais conserver le mot
    text := RegExReplace(text, "#(\w+)", "$1")
    ; Supprimer les dièses des titres markdown (# Titre, ## Titre, etc.) mais conserver le texte
    text := RegExReplace(text, "m)^#{1,6}\s+(.*?)$", "$1")  ; Le m) au début active le mode multiline
    ; Ignorer les caractères spécifiques restants
    charactersToIgnore := ["*", "@"]
    for char in charactersToIgnore {
        text := StrReplace(text, char, "")
    }
    return text
}
