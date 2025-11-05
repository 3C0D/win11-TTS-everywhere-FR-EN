#Requires AutoHotkey v2.0

; Minimal Language Detection Test - Phase 1 Validation
#Include ..\src\TextProcessor.ahk

; Simple test functions
TestBackwardCompatibility() {
    tests := [
        {text: "Hello world", expected: "EN"},
        {text: "Bonjour le monde", expected: "FR"},
        {text: "The development of the application", expected: "EN"},
        {text: "Le développement de l'application", expected: "FR"},
        {text: "This is clearly English text", expected: "EN"},
        {text: "Ceci est clairement du texte français", expected: "FR"}
    ]
    
    passed := 0
    total := tests.Length
    
    report := "=== BACKWARD COMPATIBILITY TEST ===`n"
    
    for test in tests {
        start := A_TickCount
        result := DetectLanguage(test.text)
        end := A_TickCount
        time := end - start
        
        if (result == test.expected) {
            passed++
            status := "PASS ✅"
        } else {
            status := "FAIL ❌"
        }
        
        report .= "Text: '" . test . "' -> " . result . " (" . time . "ms) [" . status . "]`n"
    }
    
    successRate := Round((passed / total) * 100, 1)
    report .= "`nSuccess Rate: " . successRate . "% (" . passed . "/" . total . ")`n"
    report .= "Status: " . (successRate >= 80 ? "PASSED" : "FAILED") . "`n"
    
    return {passed: passed, total: total, success_rate: successRate, report: report}
}

TestExtendedDictionary() {
    tests := [
        {text: "Le développement de l'application système", expected: "FR"},
        {text: "La programmation et l'interface utilisateur", expected: "FR"},
        {text: "L'entreprise nécessite une stratégie performance", expected: "FR"},
        {text: "Théorie et méthode d'analyse", expected: "FR"},
        {text: "Stratégie d'entreprise performance", expected: "FR"}
    ]
    
    passed := 0
    total := tests.Length
    
    report := "`n=== EXTENDED FRENCH DICTIONARY TEST ===`n"
    
    for test in tests {
        result := DetectLanguage(test.text)
        confidence := GetLanguageConfidence(test.text, result)
        
        if (result == test.expected) {
            passed++
            status := "PASS ✅"
        } else {
            status := "FAIL ❌"
        }
        
        report .= "Text: '" . test . "' -> " . result . " (conf: " . Round(confidence, 2) . ") [" . status . "]`n"
    }
    
    successRate := Round((passed / total) * 100, 1)
    report .= "`nSuccess Rate: " . successRate . "% (" . passed . "/" . total . ")`n"
    report .= "Status: " . (successRate >= 80 ? "PASSED" : "FAILED") . "`n"
    
    return {passed: passed, total: total, success_rate: successRate, report: report}
}

TestPerformance() {
    report := "`n=== PERFORMANCE TEST ===`n"
    
    start := A_TickCount
    
    ; Test 100 detections
    loop 50 {
        DetectLanguage("Bonjour le monde")
        DetectLanguage("Hello world")
    }
    
    end := A_TickCount
    totalTime := end - start
    avgTime := totalTime / 100
    
    report .= "100 detections in " . totalTime . "ms`n"
    report .= "Average: " . Round(avgTime, 2) . "ms per detection`n"
    report .= "Target: <= 5ms`n"
    report .= "Status: " . (avgTime <= 5 ? "PASS ✅" : "SLOW ⚠️") . "`n"
    
    return {avg_time: avgTime, report: report}
}

TestOverall() {
    ; Run all tests
    compat := TestBackwardCompatibility()
    dict := TestExtendedDictionary()
    perf := TestPerformance()
    
    ; Overall results
    overallReport := "=== PHASE 1 VALIDATION REPORT ===`n"
    overallReport .= "Generated: " . A_Now . "`n`n"
    
    overallReport .= compat.report . "`n"
    overallReport .= dict.report . "`n"
    overallReport .= perf.report . "`n"
    
    overallReport .= "=== SUMMARY ===`n"
    overallReport .= "Backward Compatibility: " . compat.success_rate . "%`n"
    overallReport .= "Extended Dictionary: " . dict.success_rate . "%`n"
    overallReport .= "Performance: " . Round(perf.avg_time, 2) . "ms average`n"
    
    overallSuccess := (compat.success_rate >= 80) && (dict.success_rate >= 80) && (perf.avg_time <= 10)
    overallReport .= "Overall Status: " . (overallSuccess ? "PHASE 1 VALIDATED ✅" : "NEEDS WORK ❌") . "`n"
    
    overallReport .= "======================================"
    
    ; Save to file
    try {
        FileAppend(overallReport, "Phase1ValidationReport.log")
    }
    
    ; Display results
    summary := "Phase 1 Validation Complete:`n`n"
    summary .= "Backward Compatibility: " . compat.success_rate . "%`n"
    summary .= "Extended Dictionary: " . dict.success_rate . "%`n"
    summary .= "Performance: " . Round(perf.avg_time, 2) . "ms`n`n"
    summary .= "Overall: " . (overallSuccess ? "VALIDATED ✅" : "NEEDS WORK ❌") . "`n`n"
    summary .= "See Phase1ValidationReport.log for details."
    
    MsgBox(summary, "Phase 1 Validation Results")
    
    return overallSuccess
}

; Main execution
TestOverall()