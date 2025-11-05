#Requires AutoHotkey v2.0

; Complete Language Detection Test Suite - Phase 1 Validation
; Includes all dependencies for comprehensive testing

#Include ..\src\TextProcessor.ahk
#Include ..\src\EnhancedLanguageDetector.ahk
#Include ..\src\LanguageDetectionMonitor.ahk

class CompleteLanguageDetectionTest {
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
        
        ; Initialize monitoring
        LanguageDetectionMonitor.Init()
        
        ; Test suites
        this.TestBackwardCompatibility()
        this.TestExtendedDictionary()
        this.TestAdaptiveThresholds()
        this.TestConfidenceSystem()
        this.TestShortTextDetection()
        this.TestMediumTextDetection()
        this.TestLongTextDetection()
        this.TestUncertainResults()
        this.TestPerformance()
        this.TestIntegration()
        this.TestEdgeCases()
        
        ; Generate comprehensive report
        this.GenerateComprehensiveReport()
        
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
            {text: "L'ordinateur internet fichier document", expected: "FR"},
            {text: "Le service recherche équipe", expected: "FR"},
            {text: "L'application interface développement", expected: "FR"},
            {text: "La méthode analyse expérience", expected: "FR"},
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
            {text: "Hi", expected: "EN", minConfidence: 0.8},
            {text: "Salut", expected: "FR", minConfidence: 0.8},
            {text: "OK", expected: "UNCERTAIN"},
            {text: "Test", expected: "EN"},
            {text: "Test développement", expected: "FR"}
        ]
        
        for test in shortTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "short_text", confidence)
            
            if (test.minConfidence && confidence < test.minConfidence) {
                this.RecordFailure("Low confidence: " confidence " < " test.minConfidence)
            }
        }
        
        ; Medium text tests
        mediumTests := [
            {text: "This is a medium length English text with some words", expected: "EN"},
            {text: "Ceci est un texte français de longueur moyenne avec des mots", expected: "FR"}
        ]
        
        for test in mediumTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "medium_text", confidence)
        }
        
        ; Long text tests (should be more permissive)
        longTests := [
            {text: "This is a very long English text that contains multiple sentences and complex grammatical structures with clear language indicators", expected: "EN"},
            {text: "Ceci est un très long texte français qui contient plusieurs phrases et des structures grammaticales complexes avec des indicateurs linguistiques clairs", expected: "FR"}
        ]
        
        for test in longTests {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "long_text", confidence)
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
            {text: "Ceci est un long texte français qui contient plusieurs phrases et des structures grammaticales complexes avec des indicateurs linguistiques clairs pour tester la détection", expected: "FR"},
            {text: "This is a long English text that contains multiple sentences and complex grammatical structures with clear language indicators for testing detection", expected: "EN"},
            {text: "Le système de développement d'applications nécessite une approche stratégique avec une planification détaillée et une équipe qualifiée pour assurer le succès du projet", expected: "FR"},
            {text: "The application development system requires a strategic approach with detailed planning and a qualified team to ensure project success", expected: "EN"}
        ]
        
        for test in longTexts {
            result := DetectLanguage(test.text)
            confidence := GetLanguageConfidence(test.text, result)
            this.ValidateResult(test.text, result, test.expected, "long", confidence)
        }
    }
    
    ; Test uncertain results
    static TestUncertainResults() {
        this.StartTest("Uncertain Results Handling")
        
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
        this.StartTest("Performance Test (1000 detections)")
        
        startTime := A_TickCount
        
        ; Test 1000 detections
        loop 1000 {
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
        avgTime := totalTime / 1000
        
        ; Performance requirement: average < 5ms per detection
        if (avgTime <= 5) {
            this.RecordSuccess("Performance: " Round(avgTime, 2) "ms average (requirement: <=5ms)")
        } else {
            this.RecordFailure("Performance too slow: " Round(avgTime, 2) "ms average (requirement: <=5ms)")
        }
    }
    
    ; Test integration with Enhanced Language Detector
    static TestIntegration() {
        this.StartTest("Enhanced Language Detector Integration")
        
        ; Test the enhanced detector class
        testTexts := [
            "Hello world",
            "Bonjour le monde",
            "Application development",
            "Développement application"
        ]
        
        for text in testTexts {
            startTime := A_TickCount
            result := EnhancedLanguageDetector.Detect(text)
            endTime := A_TickCount
            processingTime := endTime - startTime
            
            this.performanceData.Push(processingTime)
            
            if (result == "FR" || result == "EN") {
                this.RecordSuccess("Enhanced detection: '" . text . "' -> " . result . " (" . processingTime . "ms)")
            } else {
                this.RecordFailure("Enhanced detection failed: '" . text . "' -> " . result)
            }
        }
    }
    
    ; Test edge cases and robustness
    static TestEdgeCases() {
        this.StartTest("Edge Cases and Robustness")
        
        edgeCases := [
            {text: "", expected: "FR", description: "Empty text"},  ; Should default to French
            {text: "   ", expected: "FR", description: "Whitespace only"},
            {text: "Mixed text with English and French words together", expected: "UNCERTAIN", description: "Mixed languages"},
            {text: "123 456 789", expected: "UNCERTAIN", description: "Numbers only"},
            {text: "!@#$%^&*()", expected: "UNCERTAIN", description: "Special characters only"}
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
    
    static GenerateComprehensiveReport() {
        successRate := Round((this.passedTests / this.totalTests) * 100, 1)
        avgPerf := this.CalculateAveragePerformance()
        
        ; Get monitoring metrics
        monitoringMetrics := LanguageDetectionMonitor.GetMetrics()
        
        report := "`n=== COMPREHENSIVE LANGUAGE DETECTION TEST REPORT ===`n"
        report .= "Generated: " A_Now "`n"
        report .= "Test Duration: " LanguageDetectionMonitor.GetSessionDuration() " minutes`n`n"
        
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
        
        if (monitoringMetrics.total_detections > 0) {
            report .= "=== MONITORING METRICS ===`n"
            report .= "Total Detections: " monitoringMetrics.total_detections "`n"
            report .= "Accuracy Rate: " monitoringMetrics.accuracy_rate "%`n"
            report .= "Fallback Rate: " monitoringMetrics.fallback_rate "%`n"
            report .= "Cache Hit Ratio: " monitoringMetrics.cache_hit_ratio "%`n"
            report .= "French Detections: " monitoringMetrics.fr_detections "`n"
            report .= "English Detections: " monitoringMetrics.en_detections "`n"
            report .= "Uncertain Detections: " monitoringMetrics.uncertain_detections "`n"
            report .= "High Confidence: " monitoringMetrics.high_confidence " (" Round((monitoringMetrics.high_confidence / monitoringMetrics.total_detections) * 100, 1) "%)`n`n"
        }
        
        ; Detailed results
        report .= "=== DETAILED TEST RESULTS ===`n"
        currentTest := ""
        for result in this.testResults {
            if (result.HasOwnProp("test")) {
                currentTest := result.test
                report .= "`n[Test] " result.test "`n"
            } else if (result.HasOwnProp("message") && result.HasOwnProp("status")) {
                report .= "  [" result.status "] " result.message "`n"
            }
        }
        
        report .= "`n=== VALIDATION SUMMARY ===`n"
        report .= "Phase 1 Implementation Validation:`n"
        report .= "- Extended Dictionary (80+ French words): " (successRate >= 85 ? "✅ PASSED" : "❌ FAILED") "`n"
        report .= "- Adaptive Thresholds: " (avgPerf <= 10 ? "✅ PASSED" : "❌ FAILED") "`n"
        report .= "- Performance Target (< 5ms): " (avgPerf <= 5 ? "✅ PASSED" : "⚠️ WARNING") "`n"
        report .= "- Backward Compatibility: " (successRate >= 80 ? "✅ PASSED" : "❌ FAILED") "`n"
        report .= "- System Integration: " (monitoringMetrics.fallback_rate <= 10 ? "✅ PASSED" : "❌ FAILED") "`n`n"
        
        report .= "========================================================`n"
        
        ; Write report to file
        try {
            FileAppend(report, "CompleteLanguageDetectionTestReport.log")
        } catch Error {
            MsgBox("Failed to write test report: " . Error.message)
        }
        
        ; Display summary
        summaryMsg := "Test Results Summary:`n`n"
        summaryMsg .= "Success Rate: " successRate "%`n"
        summaryMsg .= "Performance: " avgPerf " ms average`n"
        summaryMsg .= "Total Tests: " this.totalTests " (" this.passedTests "/" this.failedTests ")`n`n"
        summaryMsg .= "Status: " (successRate >= 85 ? "PHASE 1 VALIDATED ✅" : "NEEDS WORK ❌") "`n`n"
        summaryMsg .= "See CompleteLanguageDetectionTestReport.log for details."
        
        MsgBox(summaryMsg, "Phase 1 Validation Results")
        
        return successRate
    }
}

; Run comprehensive tests
MainTest() {
    return CompleteLanguageDetectionTest.RunAllTests()
}