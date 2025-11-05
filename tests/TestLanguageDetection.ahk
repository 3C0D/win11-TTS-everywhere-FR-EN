#Requires AutoHotkey v2.0

; Test suite for enhanced language detection system
; Phase 1 validation: dictionaries extension and adaptive thresholds

class LanguageDetectionTester {
    static testResults := []
    static totalTests := 0
    static passedTests := 0
    static failedTests := 0
    
    ; Run all tests
    static RunAllTests() {
        this.testResults := []
        this.totalTests := 0
        this.passedTests := 0
        this.failedTests := 0
        
        ; Test suites
        this.TestExtendedFrenchDictionary()
        this.TestAdaptiveThresholds()
        this.TestConfidenceSystem()
        this.TestShortTextDetection()
        this.TestMediumTextDetection()
        this.TestLongTextDetection()
        this.TestUncertainResults()
        this.TestPerformance()
        
        ; Generate report
        this.GenerateTestReport()
        
        return this.passedTests >= (this.totalTests * 0.85) ; 85% success rate required
    }
    
    ; Test extended French dictionary
    static TestExtendedFrenchDictionary() {
        this.StartTest("Extended French Dictionary")
        
        ; Test French technical terms
        frenchTests := [
            {text: "Le développement de l'application système", expected: "FR", category: "technical"},
            {text: "La programmation et l'interface utilisateur", expected: "FR", category: "tech"},
            {text: "L'entreprise nécessite une stratégie performance", expected: "FR", category: "business"},
            {text: "L'analyse des données réseau", expected: "FR", category: "data"},
            {text: "Le projet d'équipe information", expected: "FR", category: "project"},
            {text: "La solution client technologie", expected: "FR", category: "service"},
            {text: "L'ordinateur internet fichier document", expected: "FR", category: "tech"},
            {text: "Le service recherche équipe", expected: "FR", category: "org"},
            {text: "L'application interface développement", expected: "FR", category: "app"},
            {text: "La méthode analyse expérience", expected: "FR", category: "method"}
        ]
        
        for test in frenchTests {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, test.category)
        }
    }
    
    ; Test adaptive thresholds
    static TestAdaptiveThresholds() {
        this.StartTest("Adaptive Thresholds")
        
        ; Short text tests (should be more conservative)
        shortTests := [
            {text: "Hi", expected: "EN", threshold: 3},
            {text: "Salut", expected: "FR", threshold: 2},
            {text: "OK", expected: "UNCERTAIN"}, ; Should be uncertain due to length
            {text: "Test", expected: "EN"}, ; Clear English word
            {text: "Test développement", expected: "FR"} ; French word present
        ]
        
        for test in shortTests {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, "short_text")
        }
        
        ; Long text tests (should be more permissive)
        longTests := [
            {text: "This is a very long English text that contains multiple sentences and complex grammatical structures with clear language indicators", expected: "EN", threshold: 1},
            {text: "Ceci est un très long texte français qui contient plusieurs phrases et des structures grammaticales complexes avec des indicateurs linguistiques clairs", expected: "FR", threshold: 1}
        ]
        
        for test in longTests {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, "long_text")
        }
    }
    
    ; Test confidence system
    static TestConfidenceSystem() {
        this.StartTest("Confidence System")
        
        highConfidenceTests := [
            {text: "The development of the application system requires strategic planning and performance optimization", expected: "EN", minConfidence: 0.8},
            {text: "Le développement de l'application système nécessite une planification stratégique", expected: "FR", minConfidence: 0.8},
            {text: "Hello world this is clearly English text with multiple indicators", expected: "EN", minConfidence: 0.9},
            {text: "Bonjour monde ceci est clairement du texte français", expected: "FR", minConfidence: 0.9}
        ]
        
        for test in highConfidenceTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "confidence_" . test.minConfidence)
            
            if (confidence < test.minConfidence) {
                this.RecordFailure("Low confidence: " confidence " < " test.minConfidence)
            }
        }
    }
    
    ; Test specific text lengths
    static TestShortTextDetection() {
        this.StartTest("Short Text Detection (< 10 chars)")
        
        shortTexts := [
            {text: "Bonjour", expected: "FR"},
            {text: "Hello", expected: "EN"},
            {text: "Oui", expected: "FR"},
            {text: "Yes", expected: "EN"},
            {text: "Merci", expected: "FR"},
            {text: "Thanks", expected: "EN"}
        ]
        
        for test in shortTexts {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, "short")
        }
    }
    
    static TestMediumTextDetection() {
        this.StartTest("Medium Text Detection (10-50 chars)")
        
        mediumTexts := [
            {text: "Bonjour, comment allez-vous aujourd'hui ?", expected: "FR"},
            {text: "Hello, how are you doing today?", expected: "EN"},
            {text: "Le développement de l'application système", expected: "FR"},
            {text: "The application development requires testing", expected: "EN"}
        ]
        
        for test in mediumTexts {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, "medium")
        }
    }
    
    static TestLongTextDetection() {
        this.StartTest("Long Text Detection (> 50 chars)")
        
        longTexts := [
            {text: "Ceci est un long texte français qui contient plusieurs phrases et des structures grammaticales complexes avec des indicateurs linguistiques clairs pour tester la détection", expected: "FR"},
            {text: "This is a long English text that contains multiple sentences and complex grammatical structures with clear language indicators for testing detection", expected: "EN"},
            {text: "Le système de développement d'applications nécessite une approche stratégique avec une planification détaillée et une équipe qualifiée pour assurer le succès du projet", expected: "FR"},
            {text: "The application development system requires a strategic approach with detailed planning and a qualified team to ensure project success", expected: "EN"}
        ]
        
        for test in longTexts {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, "long")
        }
    }
    
    ; Test uncertain results
    static TestUncertainResults() {
        this.StartTest("Uncertain Results")
        
        uncertainTests := [
            {text: "OK", expected: "UNCERTAIN"},
            {text: "?", expected: "UNCERTAIN"},
            {text: "123", expected: "UNCERTAIN"},
            {text: "!@#$%", expected: "UNCERTAIN"}
        ]
        
        for test in uncertainTests {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.text, result, test.expected, "uncertain")
        }
    }
    
    ; Performance test
    static TestPerformance() {
        this.StartTest("Performance Test")
        
        startTime := A_TickCount
        
        ; Test 1000 detections
        loop 1000 {
            DetectLanguage("Bonjour le monde")
            DetectLanguage("Hello world")
        }
        
        endTime := A_TickCount
        totalTime := endTime - startTime
        avgTime := totalTime / 1000
        
        ; Performance requirement: average < 5ms per detection
        if (avgTime <= 5) {
            this.RecordSuccess("Performance: " avgTime "ms average")
        } else {
            this.RecordFailure("Performance too slow: " avgTime "ms average (requirement: <=5ms)")
        }
    }
    
    ; Helper methods
    static StartTest(testName) {
        this.testResults.Push({test: testName, status: "running", time: A_Now})
    }
    
    static ValidateResult(text, result, expected, category) {
        this.totalTests++
        
        if (result == expected) {
            this.passedTests++
            this.RecordSuccess("Test passed: '" text "' -> " result)
        } else {
            this.failedTests++
            this.RecordFailure("Test failed: '" text "' -> Expected: " expected ", Got: " result)
        }
    }
    
    static RecordSuccess(message) {
        this.testResults.Push({status: "success", message: message, time: A_Now})
    }
    
    static RecordFailure(message) {
        this.testResults.Push({status: "failure", message: message, time: A_Now})
    }
    
    static GenerateTestReport() {
        successRate := Round((this.passedTests / this.totalTests) * 100, 1)
        
        report := "`n=== LANGUAGE DETECTION TEST REPORT ===`n"
        report .= "Date: " A_Now "`n"
        report .= "Total Tests: " this.totalTests "`n"
        report .= "Passed: " this.passedTests "`n"
        report .= "Failed: " this.failedTests "`n"
        report .= "Success Rate: " successRate "%`n"
        report .= "Status: " (successRate >= 85 ? "PASSED" : "FAILED") "`n"
        report .= "========================================`n`n"
        
        ; Add detailed results
        report .= "DETAILED RESULTS:`n"
        for result in this.testResults {
            if (result.HasOwnProp("status") && result.HasOwnProp("message")) {
                report .= "[" result.status "] " result.message "`n"
            }
        }
        
        ; Write report to file
        try {
            FileAppend(report, "LanguageDetectionTestReport.log")
        } catch Error {
            MsgBox("Failed to write test report: " . Error.message)
        }
        
        ; Display summary
        MsgBox(report, "Test Results", "OK Iconi")
        
        return successRate
    }
    
    ; Export results to CSV for analysis
    static ExportToCSV(filename := "language_detection_results.csv") {
        csv := "Text,Expected,Actual,Category,Status,Confidence`n"
        
        ; Add summary
        csv .= "SUMMARY,,,,,"`n
        csv .= "Total Tests," . this.totalTests . ",,,"`n
        csv .= "Passed," . this.passedTests . ",,,"`n
        csv .= "Failed," . this.failedTests . ",,,"`n
        csv .= "Success Rate," . Round((this.passedTests / this.totalTests) * 100, 1) . "%,,,"`n`n"
        
        ; Add detailed results
        csv .= "DETAILED RESULTS,,,,,"`n"
        for result in this.testResults {
            if (result.HasOwnProp("test")) {
                csv .= "Test: " result.test . ",,,,"`n"
            } else if (result.HasOwnProp("message") && result.HasOwnProp("status")) {
                csv .= ",," . result.status . "," . result.message . ",`n"
            }
        }
        
        try {
            FileAppend(csv, filename)
        } catch Error {
            MsgBox("Failed to export CSV: " . Error.message)
        }
    }
}

; Quick test function for development
RunQuickTest() {
    MsgBox("Running quick language detection test...")
    
    testCases := [
        "Bonjour le monde",
        "Hello world", 
        "Le développement système",
        "Application development",
        " Ceci est du français ",
        " This is English "
    ]
    
    results := []
    for text in testCases {
        result := DetectLanguage(text)
        confidence := GetLanguageConfidence(text, result)
        results.Push(text . " -> " . result . " (confidence: " . Round(confidence, 2) . ")")
    }
    
    resultsText := ""
    for result in results {
        resultsText .= result . "`n"
    }
    
    MsgBox(resultsText, "Quick Test Results")
}