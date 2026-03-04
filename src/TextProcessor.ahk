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

    ; If no paragraphs, add entire text
    if (paragraphs.Length == 0 && text != "") {
        paragraphs.Push(text)
    }

    return paragraphs
}

; ============================================================
; LANGUAGE DETECTION SYSTEM
; Architecture:
;   1. HasFrenchAccents() -> accented chars = FR (absolute)
;   2. CalculateLanguageScores() -> word + pattern scoring
;   3. DetectLanguage() -> final decision (FR or EN)
;   4. DetermineDominantLanguage() -> multi-paragraph wrapper
; ============================================================

; Check for French-specific accented characters
; These are NEVER found in standard English text
; This is the only truly absolute indicator
HasFrenchAccents(text) {
    frenchChars := "éèêëàâäôöùûüçÉÈÊËÀÂÄÔÖÙÛÜÇ"
    for char in StrSplit(text) {
        if InStr(frenchChars, char) {
            return true
        }
    }
    return false
}

; Calculate language scores for a given text
; Returns scores via ByRef parameters
CalculateLanguageScores(text, &frenchScore, &englishScore) {
    frenchScore := 0
    englishScore := 0

    ; --- STEP 1: French accents = strong FR bonus ---
    ; Accents are quasi-exclusive to French
    if (HasFrenchAccents(text)) {
        frenchScore += 10
    }

    ; --- STEP 2: Word-based scoring ---
    ; French common words (only words that DON'T exist
    ; as common English words)
    frenchWords := [
        ; Articles / determinants
        "le", "la", "les", "un", "une", "des", "du", "aux",
        ; Pronouns
        "je", "tu", "il", "elle", "nous", "vous", "on", "se", "me",
        "ils", "elles",
        "mon", "ton", "notre", "votre", "leur",
        ; Conjunctions / prepositions
        "et", "ou", "si", "mais", "donc", "ni", "car",
        "que", "qui", "quoi", "dont",
        "pour", "par", "avec", "dans", "sur", "sous", "sans",
        "depuis", "pendant", "vers", "chez", "parmi",
        ; Adverbs / expressions
        "très", "bien", "plus", "moins",
        "aussi", "ainsi", "alors", "donc",
        "déjà", "encore", "surtout", "pourtant", "enfin",
        "beaucoup", "toujours", "jamais",
        "maintenant", "demain", "hier",
        "voici", "voila",
        "quelque", "chaque",
        "tout", "tous", "toute", "toutes",
        "rien", "personne",
        ; Common verbs
        "peut", "faut", "doit", "va",
    ]

    ; English common words
    englishWords := [
        "the", "and", "or", "but", "so", "yet",
        "nor", "that", "which", "who", "whom",
        "whose", "when", "where", "why", "how",
        "a", "an", "in", "on", "at", "with", "by",
        "this", "these", "those",
        "is", "are", "was", "were",
        "be", "been", "being",
        "have", "has", "had",
        "do", "does", "did",
        "will", "would", "shall", "should",
        "we", "to", "of", "them", "it",
        "you", "he", "she", "they",
        "my", "your", "his", "her", "our", "their",
        "me", "him", "us",
        "as", "if", "can", "could",
        "may", "might", "must",
        "about", "from", "into", "over", "under",
        "between", "through",
        "after", "before", "during", "while",
        "than", "then", "there", "here",
        "not", "no", "yes",
        "get", "got", "make", "made",
        "just", "like", "know", "see", "look",
        "some", "more", "what", "all", "out", "up",
        "new", "good", "great", "time",
    ]

    ; Distinctive words (extra weight: +2)
    ; Words strongly tied to one language
    distinctiveFrench := [
        "est", "sont", "avoir", "fait",
        "comme", "encore", "quelqu'un",
        "aujourd'hui", "quelque chose",
        "parce", "puisque", "lorsque", "quand", "afin",
        "oui", "non",
    ]
    distinctiveEnglish := [
        "very", "much", "always", "never",
        "would", "could", "should",
        "might", "shall", "will",
        "thing", "think", "thought",
        "something", "anything",
        "nothing", "everything",
    ]

    ; Split text into words, normalize to lowercase
    words := StrSplit(StrLower(text), " ")
    for word in words {
        ; Regular word scoring (+1)
        if (HasVal(frenchWords, word))
            frenchScore++
        if (HasVal(englishWords, word))
            englishScore++

        ; Distinctive word scoring (+2)
        if (HasVal(distinctiveFrench, word))
            frenchScore += 2
        if (HasVal(distinctiveEnglish, word))
            englishScore += 2
    }

    ; --- STEP 3: Pattern-based scoring ---

    ; French apostrophe contractions
    ; (?<=\s|^) = preceded by space or start of string
    ; This avoids matching English contractions like
    ; "don't" where n' appears mid-word
    frenchPatterns := [
        "(?<=\s|^)qu'",   ; qu'il, qu'elle, qu'on
        "(?<=\s|^)l'",    ; l'eau, l'ami
        "(?<=\s|^)d'",    ; d'abord, d'accord
        "(?<=\s|^)n'",    ; n'est, n'ont
        "(?<=\s|^)c'",    ; c'est
        "(?<=\s|^)s'",    ; s'est
        "(?<=\s|^)j'",    ; j'ai
        "(?<=\s|^)m'",    ; m'a
        "(?<=\s|^)t'",    ; t'as
    ]
    for pattern in frenchPatterns {
        if (RegExMatch(text, "i)" . pattern))
            frenchScore += 3
    }

    ; English contractions and suffixes
    ; These patterns are exclusive to English
    englishPatterns := [
        "'t\b",      ; don't, can't, won't, isn't
        "'ve\b",     ; I've, we've, they've
        "'re\b",     ; you're, we're, they're
        "'ll\b",     ; I'll, you'll, he'll
        "'s\b",      ; it's, he's, that's
        "'d\b",      ; I'd, you'd, he'd
        "ness\b",    ; happiness, darkness
        "ful\b",     ; beautiful, helpful
        "less\b",    ; useless, endless
        "ize\b",     ; optimize, realize
        "ise\b",     ; recognise, analyse
    ]
    for pattern in englishPatterns {
        if (RegExMatch(text, "i)" . pattern))
            englishScore += 3
    }
}

; Detect language of a single text segment
; Returns "FR" or "EN" (no UNCERTAIN - always decide)
DetectLanguage(text, contextLanguage := "") {
    frenchScore := 0
    englishScore := 0

    CalculateLanguageScores(text, &frenchScore, &englishScore)

    ; If scores are equal or both zero, use context or
    ; default to French
    if (frenchScore == englishScore) {
        if (contextLanguage != "")
            return contextLanguage
        return "FR"  ; Default to French
    }

    ; Higher score wins
    if (frenchScore > englishScore) {
        return "FR"
    } else {
        return "EN"
    }
}

; Analyze text and determine dominant language
; Uses paragraph-by-paragraph analysis for longer texts
DetermineDominantLanguage(text) {
    paragraphs := SplitIntoParagraphs(text)

    totalFrenchScore := 0
    totalEnglishScore := 0

    for paragraph in paragraphs {
        if (paragraph == "")
            continue

        frenchScore := 0
        englishScore := 0
        CalculateLanguageScores(
            paragraph,
            &frenchScore,
            &englishScore
        )

        totalFrenchScore += frenchScore
        totalEnglishScore += englishScore
    }

    ; Default to French if scores are equal
    if (totalEnglishScore > totalFrenchScore) {
        return "EN"
    } else {
        return "FR"
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

    ; Ignore dashes (---) - replace with nothing
    text := RegExReplace(text, "---+", "")

    ; Ignore web addresses (http://, https://, www.)
    text := RegExReplace(text, "https?://[^\s]+", "")
    text := RegExReplace(text, "www\.[^\s]+", "")

    ; Ignore file paths
    text := RegExReplace(
        text,
        "[A-Za-z]:\\[^\s\\/:*?" "<>|]+(?:\\[^\s\\/:*?" "<>|]+)+",
        ""
    )  ; Windows paths
    text := RegExReplace(
        text, "/(?:[^\s/]+/)+", ""
    )  ; Unix/Linux paths

    ; Ignore double slashes
    text := RegExReplace(text, "//", "")
    ; Replace isolated backslashes with word
    text := RegExReplace(
        text, "(?<!\S)\\(?!\S)", " backslash "
    )
    ; Replace isolated slashes with word
    text := RegExReplace(
        text, "(?<!\S)/(?!\S)", " slash "
    )
    ; Remove hash from hashtags but keep word
    text := RegExReplace(text, "#(\w+)", "$1")
    ; Remove hashes from markdown titles
    text := RegExReplace(
        text, "m)^#{1,6}\s+(.*?)$", "$1"
    )

    ; Ignore underscores in all words
    text := StrReplace(text, "_", " ")

    ; Ignore remaining specific characters
    charactersToIgnore := ["*", "@"]
    for char in charactersToIgnore {
        text := StrReplace(text, char, "")
    }

    ; Remove Unicode / emoticons (keep ASCII + French)
    text := RegExReplace(
        text, "[^\x00-\x7F\xC0-\xFF]", ""
    )

    return text
}
