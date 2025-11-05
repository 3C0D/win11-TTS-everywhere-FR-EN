#Requires AutoHotkey v2.0
#include ..\src\TextProcessor.ahk
#include ..\src\EnhancedLanguageDetector.ahk

; Test multiple sentences to validate French detection improvements
testCases := [
    "Processing : Utilise DetectLanguage() et GetLanguageConfidence() du système actuel",
    "Le système fonctionne bien avec les accents français",
    "This is a pure English sentence for comparison",
    "Analyse du problème avec la méthode et les paramètres",
    "Configuration and setup of the application"
]

for i, testText in testCases {
    ; Get scores
    frenchScore := 0
    englishScore := 0
    CalculateLanguageScores(testText, &frenchScore, &englishScore)

    ; Get language detection result
    language := DetectLanguage(testText)
    confidence := GetLanguageConfidence(testText, language)

    ; Display detailed results
    result := "Text " . i . ": " . testText . "`n`n"
    result .= "French Score: " . frenchScore . "`n"
    result .= "English Score: " . englishScore . "`n"
    result .= "Language: " . language . "`n"
    result .= "Confidence: " . Round(confidence * 100, 1) . "%`n"
    result .= "Length: " . StrLen(testText) . " chars"
    
    MsgBox(result, "Test Case " . i . " - French Detection Validation")
}

MsgBox("Test completed! All results displayed above.", "Test Summary")
ExitApp