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

; Priority detection for French-specific indicators
; Returns true if text contains French-specific characters or words that guarantee French detection
HasFrenchPriorityIndicators(text) {
    ; French-specific accented characters that are NEVER found in English
    frenchSpecificChars := "éèêëàâäôöùûüçÉÈÊËÀÂÄÔÖÙÛÜÇ"
    
    ; Check for French-specific accented characters
    for char in StrSplit(text) {
        if InStr(frenchSpecificChars, char) {
            return true  ; Quasi-absolute priority for French
        }
    }
    
    ; French-specific words WITHOUT ACCENTS that are NEVER found in English (case-insensitive)
    ; Only words that don't contain accented characters (those are already caught above)
    textLower := StrLower(text)
    frenchGuaranteedWords := [
        ; Articles and determinants specific to French (no accents)
        "le", "la", "les", "du", "des", "au", "aux", "un", "une",
        ; French-specific conjunctions and prepositions (no accents)
        "chez", "parmi", "dans", "sur", "sous", "avec", "sans", "pour", "par", "dont",
        ; French-specific adverbs and expressions (no accents)
        "donc", "alors", "ainsi", "aussi", "voici", "voila", "beaucoup", "toujours", "jamais",
        "encore", "maintenant", "demain", "hier", "quelque", "chaque", "tout", "tous", "toute", "toutes",
        "rien", "personne", "quelqu'un",
        ; French-specific verbs (no accents)
        "avoir", "fait", "sont", "suis", "sommes", "avons", "avez", "ont"
    ]
    
    ; Check for guaranteed French words (with word boundaries)
    for word in frenchGuaranteedWords {
        ; Use word boundaries to avoid partial matches
        if RegExMatch(textLower, "\b" . word . "\b") {
            return true  ; Quasi-absolute priority for French
        }
    }
    
    ; French-specific apostrophe patterns (contractions) - with word boundary to avoid English false positives
    ; The \b ensures we match French contractions like "d'abord" but NOT "don't"
    frenchApostrophePatterns := [
        "\\bqu'[aeiouy]",    ; qu'il, qu'elle, qu'on, qu'un, etc.
        "\\bl'[aeiouy]",     ; l'eau, l'ami, l'école, etc.
        "\\bd'[aeiouy]",     ; d'abord, d'accord, d'eau, etc.
        "\\bn'[aeiouy]",     ; n'est, n'ont, n'importe, etc.
        "\\bc'est",          ; c'est
        "\\bs'est",          ; s'est
        "\\bj'[aeiouy]",     ; j'ai, j'étais, etc.
        "\\bm'[aeiouy]",     ; m'a, m'ont, etc.
        "\\bt'[aeiouy]",     ; t'as, t'es, etc.
    ]
    
    for pattern in frenchApostrophePatterns {
        if RegExMatch(textLower, pattern) {
            return true  ; Quasi-absolute priority for French
        }
    }
    
    return false
}

; Calculate language scores for a given text
CalculateLanguageScores(text, &frenchScore, &englishScore) {
    ; Language detection based on common words and patterns
    ; Extended French dictionary to balance with English (80+ words)
    frenchWords := ["le", "la", "les", "un", "une", "des", "et", "ou", "mais", "donc", "or", "ni", "car", "que", "qui",
        "quoi", "dont", "où", "à", "au", "avec", "pour", "sur", "dans", "par", "ce", "cette", "ces", "je", "tu", "il",
        "elle", "nous", "vous", "ils", "elles", "mon", "ton", "son", "notre", "votre", "leur", "développement",
        "programmation", "système", "application", "interface", "recherche", "expérience", "théorie", "méthode",
        "analyse", "entreprise", "management", "stratégie", "performance", "communication", "information",
        "technologie", "ordinateur", "internet", "réseau", "données", "fichier", "document", "projet", "équipe",
        "service", "client", "produit", "solution", "problème", "question", "réponse", "proposition", "demande",
        "travail", "mission", "objectif", "résultat", "conviction", "opinion", "position", "côté", "exemple",
        "modèle", "cas", "situation", "contexte", "moment", "époque", "période", "temps", "durée", "instant"
    ]
    englishWords := ["the", "and", "or", "but", "so", "yet", "for", "nor", "that", "which", "who", "whom", "whose",
        "when", "where", "why", "how", "a", "an", "in", "on", "at", "with", "by", "this", "these", "those", "is", "are",
        "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "shall",
        "should", "we", "to", "of", "them", "it", "you", "he", "she", "they", "my", "your", "his", "her", "our",
        "their",
        "me", "him", "us", "as", "if", "can", "could", "may", "might", "must", "about", "from", "into", "over", "under",
        "between", "through", "after", "before", "during", "while", "than", "then", "there", "here", "not", "no", "yes"
    ]

    ; Add weight to more distinctive words
    distinctiveFrench := ["est", "sont", "être", "avoir", "fait", "très", "beaucoup", "toujours", "jamais", "voilà",
        "donc", "alors", "puis", "ainsi", "comme", "aussi", "même", "encore", "déjà", "maintenant", "aujourd'hui",
        "demain", "hier", "ici", "là", "chose", "quelque", "chaque", "tout", "tous", "toute", "toutes", "rien",
        "personne", "quelqu'un", "quelque chose"]
    distinctiveEnglish := ["is", "are", "be", "have", "do", "very", "much", "always", "never", "would", "could",
        "should", "might", "must", "shall", "will", "can", "don't", "doesn't", "didn't", "won't", "wasn't", "weren't",
        "hasn't", "haven't", "hadn't", "isn't", "aren't", "wouldn't", "couldn't", "shouldn't", "thing", "think",
        "thought", "something", "anything", "nothing", "everything"]

    frenchScore := 0
    englishScore := 0

    ; NOTE: Accent detection is now handled by HasFrenchPriorityIndicators()
    ; This function only handles word-based scoring for non-priority cases

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

    ; Check for language-specific patterns (with word boundaries to avoid English false positives)
    if (RegExMatch(text, "i)\\bqu'[aeiouy]|\\bc'est|\\bn'[aeiouy]|\\bl'[aeiouy]|\\bd'[aeiouy]"))
        frenchScore += 3
    if (RegExMatch(text, "i)ing\\s|ed\\s|'s\\s|'ve\\s|'re\\s|'ll\\s|'t\\s|'d\\s|th\\s|wh\\s"))
        englishScore += 4  ; Increased weight for English patterns
}

DetectLanguage(text, contextLanguage := "") {
    ; PRIORITY CHECK: French-specific characters and words with quasi-absolute priority
    if (HasFrenchPriorityIndicators(text)) {
        return "FR"
    }
    
    ; Enhanced language detection with adaptive thresholds
    frenchScore := 0
    englishScore := 0

    CalculateLanguageScores(text, &frenchScore, &englishScore)

    textLength := StrLen(text)
    
    ; Adaptive thresholds based on text length - Balanced for French preference
    if (textLength <= 10) {
        ; Short text (1-10 chars): balanced thresholds with French advantage
        englishThreshold := 2
        frenchThreshold := 1
        confidenceRequired := 0.7
    } else if (textLength <= 50) {
        ; Medium text (11-50 chars): French advantage for mixed technical content
        englishThreshold := 2
        frenchThreshold := 0  ; Any French score wins
        confidenceRequired := 0.6
    } else {
        ; Long text (50+ chars): Strong French advantage for technical mixed content
        englishThreshold := 1
        frenchThreshold := 0  ; Any French score with accents wins
        confidenceRequired := 0.5
    }
    
    ; Calculate confidence score
    totalScore := frenchScore + englishScore
    if (totalScore > 0) {
        confidence := Max(frenchScore, englishScore) / totalScore
    } else {
        confidence := 0.5
    }
    
    ; Debug information (can be removed in production)
    ; Uncomment for debugging: MsgBox("Length: " textLength ", French: " frenchScore ", English: " englishScore ", Confidence: " confidence)
    
    ; Determine language based on adaptive thresholds with French bias for technical content
    if (englishScore > frenchScore && (englishScore - frenchScore) >= englishThreshold) {
        if (confidence >= confidenceRequired) {
            return "EN"
        } else {
            ; Low confidence - use context if available
            if (contextLanguage == "EN") {
                return "EN"
            }
            return "UNCERTAIN"
        }
    } else if (frenchScore > englishScore && (frenchScore - englishScore) >= frenchThreshold) {
        if (confidence >= confidenceRequired) {
            return "FR"
        } else {
            ; Low confidence - use context if available
            if (contextLanguage == "FR") {
                return "FR"
            }
            return "UNCERTAIN"
        }
    } else {
        ; Scores are close - use pattern-based detection
        if (RegExMatch(text, "i)the\s|and\s|of\s|to\s|in\s|is\s|are\s|that\s|it\s|for\s|with\s")) {
            if (contextLanguage == "EN" || contextLanguage == "") {
                return "EN"
            }
        } else {
            ; If context suggests French or no clear English indicators
            if (contextLanguage == "FR" || contextLanguage == "") {
                return "FR"
            }
        }
        
        return "UNCERTAIN" ; Unable to determine with sufficient confidence
    }
}

; Get confidence score for language detection
GetLanguageConfidence(text, language) {
    frenchScore := 0
    englishScore := 0
    
    CalculateLanguageScores(text, &frenchScore, &englishScore)
    
    totalScore := frenchScore + englishScore
    if (totalScore == 0) {
        return 0.5
    }
    
    if (language == "FR") {
        return frenchScore / totalScore
    } else if (language == "EN") {
        return englishScore / totalScore
    } else {
        return 0.5
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

    ; Ignore dashes (---) that are read as "--" - replace with nothing for section separators
    text := RegExReplace(text, "---+", "")

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

    ; Ignore underscores in all words (not just at start/end)
    text := StrReplace(text, "_", " ")

    ; Ignore remaining specific characters
    charactersToIgnore := ["*", "@"]
    for char in charactersToIgnore {
        text := StrReplace(text, char, "")
    }

    ; NEW: Ignore Unicode characters and emoticons (keep only basic ASCII and accented French characters)
    ; This removes emojis and other Unicode symbols that are read aloud by TTS
    ; Simple formula: remove all characters outside the basic ASCII range and French accented characters
    text := RegExReplace(text, "[^\x00-\x7F\xC0-\xFF]", "")  ; Keep ASCII (0-127) and Latin-1 Supplement (128-255)
    
    return text
}
