#Requires AutoHotkey v2.0

; Functions for text processing and language detection

; Function to split text into paragraphs
SplitIntoParagraphs(text) {
    ; Simple method: consider each line as a paragraph
    ; This ensures the text is read line by line
    paragraphs := []

    ; Split text into lines
    lines := StrSplit(text, "`n")

    ; Add each non-empty line as a paragraph
    for line in lines {
        ; Ignore empty lines
        if (!RegExMatch(line, "^\s*$")) {
            paragraphs.Push(line)
        }
    }

    ; If no paragraphs were found, add the entire text as a single paragraph
    if (paragraphs.Length == 0 && text != "") {
        paragraphs.Push(text)
    }

    return paragraphs
}

; Analyze text and determine dominant language based on word count
DetermineDominantLanguage(text) {
    ; Split text into paragraphs
    paragraphs := SplitIntoParagraphs(text)

    ; Initialize counters for words in each language
    totalFrenchScore := 0
    totalEnglishScore := 0
    totalWordCount := 0

    ; Analyze each paragraph
    for paragraph in paragraphs {
        ; Skip empty paragraphs
        if (paragraph == "")
            continue

        ; Get language scores for this paragraph
        frenchScore := 0
        englishScore := 0
        CalculateLanguageScores(paragraph, &frenchScore, &englishScore)

        ; Add to total scores
        totalFrenchScore += frenchScore
        totalEnglishScore += englishScore

        ; Count words in paragraph for weighting
        words := StrSplit(paragraph, " ")
        totalWordCount += words.Length
    }

    ; Determine dominant language based on total scores
    if (totalEnglishScore > totalFrenchScore) {
        return "EN"
    } else {
        return "FR" ; Default to French if scores are equal
    }
}

; Calculate language scores for a given text
CalculateLanguageScores(text, &frenchScore, &englishScore) {
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
}

DetectLanguage(text) {
    ; Language detection based on common words and patterns
    frenchScore := 0
    englishScore := 0

    CalculateLanguageScores(text, &frenchScore, &englishScore)

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
    ; Ignore characters repeated more than 4 times
    text := RegExReplace(text, "(.)\1{4,}", "")

    ; First ignore web addresses (http://, https://, www.)
    ; The ? after the s makes the s optional, so this rule captures http:// and https://
    text := RegExReplace(text, "https?://[^\s]+", "")
    ; This rule captures URLs starting with www.
    text := RegExReplace(text, "www\.[^\s]+", "")

    ; Ignore file paths (containing multiple slashes or backslashes)
    text := RegExReplace(text, "[A-Za-z]:\\[^\s\\/:*?" "<>|]+(?:\\[^\s\\/:*?" "<>|]+)+", "")  ; Windows paths
    text := RegExReplace(text, "/(?:[^\s/]+/)+", "")  ; Unix/Linux paths

    ; Ignore double slashes (//) but keep single slashes (/)
    text := RegExReplace(text, "//", "")
    ; Replace isolated backslashes with the word "backslash" so the TTS engine reads them
    text := RegExReplace(text, "(?<!\S)\\(?!\S)", " backslash ")
    ; Replace isolated slashes with the word "slash" so the TTS engine reads them consistently
    text := RegExReplace(text, "(?<!\S)/(?!\S)", " slash ")
    ; Remove the hash from hashtags (#word) but keep the word
    text := RegExReplace(text, "#(\w+)", "$1")
    ; Remove hashes from markdown titles (# Title, ## Title, etc.) but keep the text
    text := RegExReplace(text, "m)^#{1,6}\s+(.*?)$", "$1")  ; The m) at the beginning enables multiline mode
    ; Ignore remaining specific characters
    charactersToIgnore := ["*", "@"]
    for char in charactersToIgnore {
        text := StrReplace(text, char, "")
    }
    return text
}
