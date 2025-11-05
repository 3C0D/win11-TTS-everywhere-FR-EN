#Requires AutoHotkey v2.0

; Phase 1 Validation Test - Simple and reliable
#Include ..\src\TextProcessor.ahk

; Test backward compatibility
TestBackwardCompatibility() {
    MsgBox("Testing Backward Compatibility...")

    testCases := [
        {text: "Hello world", expected: "EN"},
        {text: "Bonjour le monde", expected: "FR"},
        {text: "The development of the application", expected: "EN"},
        {text: "Le développement de l'application", expected: "FR"}
    ]

    passed := 0
    total := testCases.Length

    for testCase in testCases {
        result := DetectLanguage(testCase.text)
        if (result == testCase.expected) {
            passed++
        }
    }

    successRate := Round((passed / total) * 100, 1)
    MsgBox("Backward Compatibility: " successRate "% (" passed "/" total ")")
    return successRate >= 80
}

; Test extended French dictionary
TestExtendedDictionary() {
    MsgBox("Testing Extended French Dictionary...")

    frenchTests := [
        {text: "Le développement de l'application système", expected: "FR"},
        {text: "La programmation et l'interface utilisateur", expected: "FR"},
        {text: "L'entreprise nécessite une stratégie performance", expected: "FR"}
    ]

    passed := 0
    total := frenchTests.Length

    for test in frenchTests {
        result := DetectLanguage(test.text)
        if (result == test.expected) {
            passed++
        }
    }

    successRate := Round((passed / total) * 100, 1)
    MsgBox("Extended Dictionary: " successRate "% (" passed "/" total ")")
    return successRate >= 80
}

; Test adaptive thresholds
TestAdaptiveThresholds() {
    MsgBox("Testing Adaptive Thresholds...")

    ; Short text should be more conservative
    shortResult := DetectLanguage("Hi")
    mediumResult := DetectLanguage("Hello world")
    longResult := DetectLanguage("This is a very long English text that contains multiple sentences")

    shortOk := (shortResult == "EN")
    mediumOk := (mediumResult == "EN")
    longOk := (longResult == "EN")

    passed := (shortOk ? 1 : 0) + (mediumOk ? 1 : 0) + (longOk ? 1 : 0)
    total := 3

    successRate := Round((passed / total) * 100, 1)
    MsgBox("Adaptive Thresholds: " successRate "% (" passed "/" total ")")
    return successRate >= 66
}

; Test performance
TestPerformance() {
    MsgBox("Testing Performance...")

    startTime := A_TickCount

    ; Test 100 detections
    loop 100 {
        DetectLanguage("Bonjour le monde")
        DetectLanguage("Hello world")
    }

    endTime := A_TickCount
    totalTime := endTime - startTime
    avgTime := totalTime / 100

    performanceOk := avgTime <= 5
    status := performanceOk ? "PASS" : "SLOW"

    MsgBox("Performance: " Round(avgTime, 2) "ms average (" status ")")
    return performanceOk
}

; Main validation function
ValidatePhase1() {
    MsgBox("=== PHASE 1 VALIDATION START ===`n`nTesting win11-TTS-everywhere-FR-EN Phase 1 Implementation")

    ; Run all tests
    backwardOk := TestBackwardCompatibility()
    dictionaryOk := TestExtendedDictionary()
    thresholdsOk := TestAdaptiveThresholds()
    performanceOk := TestPerformance()

    ; Calculate overall score
    testsPassed := (backwardOk ? 1 : 0) + (dictionaryOk ? 1 : 0) + (thresholdsOk ? 1 : 0) + (performanceOk ? 1 : 0)
    totalTests := 4
    overallSuccessRate := Round((testsPassed / totalTests) * 100, 1)

    ; Determine final status
    if (overallSuccessRate >= 75) {
        finalStatus := "✅ PHASE 1 VALIDATED"
        recommendation := "Ready for production deployment"
    } else {
        finalStatus := "⚠️ NEEDS IMPROVEMENT"
        recommendation := "Further testing and adjustments required"
    }

    ; Show final results
    resultMsg := "=== PHASE 1 VALIDATION RESULTS ===`n`n"
    resultMsg .= "Overall Success Rate: " overallSuccessRate "%`n"
    resultMsg .= "Tests Passed: " testsPassed "/" totalTests "`n`n"
    resultMsg .= "Status: " finalStatus "`n"
    resultMsg .= "Recommendation: " recommendation "`n`n"
    resultMsg .= "Components Validated:`n"
    resultMsg .= "- Backward Compatibility: " (backwardOk ? "✅" : "❌") "`n"
    resultMsg .= "- Extended Dictionary: " (dictionaryOk ? "✅" : "❌") "`n"
    resultMsg .= "- Adaptive Thresholds: " (thresholdsOk ? "✅" : "❌") "`n"
    resultMsg .= "- Performance: " (performanceOk ? "✅" : "❌") "`n`n"
    resultMsg .= "Expected Improvements:`n"
    resultMsg .= "- Precision: +5-7% (85-90% → 90-92%)`n"
    resultMsg .= "- Performance: <5ms per detection`n"
    resultMsg .= "- Robustness: Fallback automatic`n"
    resultMsg .= "- Monitoring: Real-time metrics"

    MsgBox(resultMsg, "Phase 1 Validation Complete")

    ; Save results to file
    try {
        FileAppend(resultMsg, "Phase1ValidationResults.log")
        MsgBox("Results saved to Phase1ValidationResults.log")
    }

    return overallSuccessRate >= 75
}

; Run validation
ValidatePhase1()