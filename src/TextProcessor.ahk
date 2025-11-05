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

    ; Count French-specific characters (adds to French score)
    frenchChars := "éèêëàâäôöùûüçÉÈÊËÀÂÄÔÖÙÛÜÇ"
    for char in StrSplit(text) {
        if InStr(frenchChars, char)
            frenchScore += 2  ; Strong weight to accented characters - very French-specific
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
    if (RegExMatch(text, "i)ing\s|ed\s|'s\s|'ve\s|'re\s|'ll\s|'t\s|'d\s|th\s|wh\s"))
        englishScore += 4  ; Increased weight for English patterns
}

DetectLanguage(text, contextLanguage := "") {
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
            ; For texts with French words and accents, prefer French even with low confidence
            hasFrenchChars := RegExMatch(text, "[éèêëàâäôöùûüç]")
            hasFrenchWords := RegExMatch(text, "i)\s(et|du|la|le|les|des|un|une|que|qui|avec|par|dans|pour)\s")
            if (hasFrenchChars || hasFrenchWords) {
                return "FR"
            }
            ; Low confidence - use context if available
            if (contextLanguage == "EN") {
                return "EN"
            }
            return "UNCERTAIN"
        }
    } else if (frenchScore > englishScore && (frenchScore - frenchScore) >= frenchThreshold) {
        if (confidence >= confidenceRequired) {
            return "FR"
        } else {
            ; Lower threshold for French - if any French score with French chars/words, accept it
            hasFrenchChars := RegExMatch(text, "[éèêëàâäôöùûüç]")
            hasFrenchWords := RegExMatch(text, "i)\s(et|du|la|le|les|des|un|une|que|qui|avec|par|dans|pour)\s")
            if (hasFrenchChars || hasFrenchWords) {
                return "FR"
            }
            ; Low confidence - use context if available
            if (contextLanguage == "FR") {
                return "FR"
            }
            return "UNCERTAIN"
        }
    } else {
        ; Scores are close - heavily bias towards French for technical mixed content
        hasFrenchChars := RegExMatch(text, "[éèêëàâäôöùûüç]")
        hasFrenchWords := RegExMatch(text, "i)\s(et|du|la|le|les|des|un|une|que|qui|avec|par|dans|pour)\s")
        
        if (hasFrenchChars || hasFrenchWords) {
            return "FR"
        }

        ; Fallback to pattern-based detection
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
    return text
}
