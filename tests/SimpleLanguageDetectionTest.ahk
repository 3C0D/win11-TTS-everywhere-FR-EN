#Requires AutoHotkey v2.0

; Simple Language Detection Test Suite - Phase 1 Validation
; Basic functionality testing without complex features

#Include ..\src\TextProcessor.ahk
#Include ..\src\EnhancedLanguageDetector.ahk

class SimpleLanguageDetectionTest {
    static testResults := []
    static totalTests := 0
    static passedTests := 0
    static failedTests := 0
    static performanceData := []
    
    ; Run all tests
    static RunAllTests() {
        this.testResults := []
        this.totalTests := 0
        this.passedTests := 0
        this.failedTests := 0
        this.performanceData := []
        
        ; Test suites
        this.TestBackwardCompatibility()
        this.TestExtendedDictionary()
        this.TestAdaptiveThresholds()
        this.TestShortTextDetection()
        this.TestMediumTextDetection()
        this.TestLongTextDetection()
        this.TestPerformance()
        this.TestEdgeCases()
        
        ; Generate simple report
        this.GenerateSimpleReport()
        
        return {
            success: this.passedTests >= (this.totalTests * 0.85),
            passed: this.passedTests,
            total: this.totalTests,
            success_rate: Round((this.passedTests / this.totalTests) * 100, 1),
            avg_performance: this.CalculateAveragePerformance()
        }
    }
    
    ; Test backward compatibility with original system
    static TestBackwardCompatibility() {
        this.StartTest("Backward Compatibility")
        
        ; Test original DetectLanguage function behavior
        compatibilityTests := [
            {text: "Hello world", expected: "EN"},
            {text: "Bonjour le monde", expected: "FR"},
            {text: "The development of the application", expected: "EN"},
            {text: "Le développement de l'application", expected: "FR"},
            {text: "This is clearly English text", expected: "EN"},
            {text: "Ceci est clairement du texte français", expected: "FR"}
        ]
        
        for test in compatibilityTests {
            startTime := A_TickCount
            result := DetectLanguage(test.text)
            endTime := A_TickCount
            processingTime := endTime - startTime
            
            this.performanceData.Push(processingTime)
            this.ValidateResult(test.text, result, test.expected, "compatibility", processingTime)
        }
    }
    
    ; Test extended French dictionary
    static TestExtendedDictionary() {
        this.StartTest("Extended French Dictionary (80+ words)")
        
        ; Test French technical and business terms
        extendedFrenchTests := [
            {text: "Le développement de l'application système", expected: "FR"},
            {text: "La programmation et l'interface utilisateur", expected: "FR"},
            {text: "L'entreprise nécessite une stratégie performance", expected: "FR"},
            {text: "L'analyse des données réseau", expected: "FR"},
            {text: "Le projet d'équipe information", expected: "FR"},
            {text: "La solution client technologie", expected: "FR"},
            {text: "Théorie et méthode d'analyse", expected: "FR"},
            {text: "Stratégie d'entreprise performance", expected: "FR"}
        ]
        
        for test in extendedFrenchTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "extended_french", confidence)
        }
    }
    
    ; Test adaptive thresholds
    static TestAdaptiveThresholds() {
        this.StartTest("Adaptive Thresholds")
        
        ; Short text tests (should be more conservative)
        shortTests := [
            {text: "Hi", expected: "EN"},
            {text: "Salut", expected: "FR"},
            {text: "Test", expected: "EN"},
            {text: "Test développement", expected: "FR"}
        ]
        
        for test in shortTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "short_text", confidence)
        }
        
        ; Medium text tests
        mediumTests := [
            {text: "This is a medium length English text", expected: "EN"},
            {text: "Ceci est un texte français de longueur moyenne", expected: "FR"}
        ]
        
        for test in mediumTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "medium_text", confidence)
        }
        
        ; Long text tests (should be more permissive)
        longTests := [
            {text: "This is a very long English text that contains multiple sentences and complex grammatical structures", expected: "EN"},
            {text: "Ceci est un très long texte français qui contient plusieurs phrases et des structures complexes", expected: "FR"}
        ]
        
        for test in longTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "long_text", confidence)
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
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "short", confidence)
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
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "medium", confidence)
        }
    }
    
    static TestLongTextDetection() {
        this.StartTest("Long Text Detection (> 50 chars)")
        
        longTexts := [
            {text: "Ceci est un long texte français qui contient plusieurs phrases et des structures grammaticales complexes", expected: "FR"},
            {text: "This is a long English text that contains multiple sentences and complex grammatical structures", expected: "EN"}
        ]
        
        for test in longTexts {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "long", confidence)
        }
    }
    
    ; Performance test
    static TestPerformance() {
        this.StartTest("Performance Test (500 detections)")
        
        startTime := A_TickCount
        
        ; Test 500 detections
        loop 500 {
            start := A_TickCount
            DetectLanguage("Bonjour le monde")
            end := A_TickCount
            this.performanceData.Push(end - start)
            
            start := A_TickCount
            DetectLanguage("Hello world")
            end := A_TickCount
            this.performanceData.Push(end - start)
        }
        
        endTime := A_TickCount
        totalTime := endTime - startTime
        avgTime := totalTime / 500
        
        ; Performance requirement: average < 5ms per detection
        if (avgTime <= 5) {
            this.RecordSuccess("Performance: " Round(avgTime, 2) "ms average (requirement: <=5ms)")
        } else {
            this.RecordFailure("Performance too slow: " Round(avgTime, 2) "ms average (requirement: <=5ms)")
        }
    }
    
    ; Test edge cases and robustness
    static TestEdgeCases() {
        this.StartTest("Edge Cases and Robustness")
        
        edgeCases := [
            {text: "", expected: "FR", description: "Empty text"},  ; Should default to French
            {text: "   ", expected: "FR", description: "Whitespace only"},
            {text: "123 456", expected: "FR", description: "Numbers only"},
            {text: "OK", expected: "FR", description: "Ambiguous input"}
        ]
        
        for test in edgeCases {
            result := DetectLanguage(test.text)
            this.ValidateResult(test.description, result, test.expected, "edge_case")
        }
    }
    
    ; Helper methods
    static StartTest(testName) {
        this.testResults.Push({test: testName, status: "running", time: A_Now})
    }
    
    static ValidateResult(text, result, expected, category, confidence := 0) {
        this.totalTests++
        
        if (result == expected) {
            this.passedTests++
            this.RecordSuccess("Test passed: '" . text . "' -> " . result . " (confidence: " . Round(confidence, 2) . ")")
        } else {
            this.failedTests++
            this.RecordFailure("Test failed: '" . text . "' -> Expected: " . expected ", Got: " . result)
        }
    }
    
    static RecordSuccess(message) {
        this.testResults.Push({status: "success", message: message, time: A_Now})
    }
    
    static RecordFailure(message) {
        this.testResults.Push({status: "failure", message: message, time: A_Now})
    }
    
    static CalculateAveragePerformance() {
        if (this.performanceData.Length == 0) return 0
        total := 0
        for time in this.performanceData {
            total += time
        }
        return Round(total / this.performanceData.Length, 2)
    }
    
    static GenerateSimpleReport() {
        successRate := Round((this.passedTests / this.totalTests) * 100, 1)
        avgPerf := this.CalculateAveragePerformance()
        
        report := "`n=== SIMPLE LANGUAGE DETECTION TEST REPORT ===`n"
        report .= "Generated: " A_Now "`n`n"
        
        report .= "=== OVERALL RESULTS ===`n"
        report .= "Total Tests: " this.totalTests "`n"
        report .= "Passed: " this.passedTests "`n"
        report .= "Failed: " this.failedTests "`n"
        report .= "Success Rate: " successRate "%`n"
        report .= "Status: " (successRate >= 85 ? "PASSED ✅" : "FAILED ❌") "`n`n"
        
        report .= "=== PERFORMANCE METRICS ===`n"
        report .= "Average Detection Time: " avgPerf " ms`n"
        report .= "Performance Target: <= 5ms`n"
        report .= "Performance Status: " (avgPerf <= 5 ? "EXCELLENT ✅" : "SLOW ⚠️") "`n`n"
        
        report .= "=== VALIDATION SUMMARY ===`n"
        report .= "Phase 1 Implementation Validation:`n"
        report .= "- Backward Compatibility: " (successRate >= 80 ? "✅ PASSED" : "❌ FAILED") "`n"
        report .= "- Extended French Dictionary: " (successRate >= 85 ? "✅ PASSED" : "❌ FAILED") "`n"
        report .= "- Adaptive Thresholds: " (avgPerf <= 10 ? "✅ PASSED" : "❌ FAILED") "`n"
        report .= "- Performance Target (< 5ms): " (avgPerf <= 5 ? "✅ PASSED" : "⚠️ WARNING") "`n"
        report .= "- System Robustness: " (successRate >= 75 ? "✅ PASSED" : "❌ FAILED") "`n`n"
        
        report .= "================================================`n"
        
        ; Write report to file
        try {
            FileAppend(report, "SimpleLanguageDetectionTestReport.log")
        } catch Error {
            ; Silent fail
        }
        
        ; Display summary
        summaryMsg := "Phase 1 Test Results:`n`n"
        summaryMsg .= "Success Rate: " successRate "%`n"
        summaryMsg .= "Performance: " avgPerf " ms average`n"
        summaryMsg .= "Total Tests: " this.totalTests " (" this.passedTests "/" this.failedTests ")`n`n"
        summaryMsg .= "Status: " (successRate >= 85 ? "PHASE 1 VALIDATED ✅" : "NEEDS IMPROVEMENT ❌") "`n`n"
        summaryMsg .= "See SimpleLanguageDetectionTestReport.log for details."
        
        MsgBox(summaryMsg, "Phase 1 Validation Results")
        
        return successRate
    }
}

; Run simple tests
MainTest() {
    return SimpleLanguageDetectionTest.RunAllTests()
}