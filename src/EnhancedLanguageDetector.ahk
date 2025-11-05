#Requires AutoHotkey v2.0

; Enhanced Language Detection System - Hybrid Architecture
; Phase 1: Improved dictionary-based detection with adaptive thresholds

class EnhancedLanguageDetector {
    static currentStrategy := "adaptive"
    static detectionCache := Map()
    static performanceMetrics := Map()
    static fallbackActive := false
    
    ; Main detection method with fallback strategy
    Detect(text) {
        text := Trim(text)
        if (text == "") {
            return "FR" ; Default fallback
        }
        
        ; Check cache first for performance
        textKey := SubStr(text, 1, 50) ; Cache key based on first 50 chars
        if (this.detectionCache.Has(textKey)) {
            this.UpdateMetrics("cache_hit")
            return this.detectionCache[textKey]
        }
        
        ; Use enhanced detection with adaptive thresholds
        startTime := A_TickCount
        result := this.EnhancedDetect(text)
        detectionTime := A_TickCount - startTime
        
        ; Cache the result for future use
        this.detectionCache[textKey] := result
        
        ; Update performance metrics
        this.UpdateMetrics("detection_time", detectionTime)
        
        return result
    }
    
    ; Enhanced detection with adaptive thresholds
    EnhancedDetect(text) {
        try {
            ; Try the new adaptive detection system
            result := DetectLanguage(text)
            
            ; Handle uncertain results with fallback
            if (result == "UNCERTAIN") {
                result := this.HandleUncertainResult(text)
            }
            
            return result
        } catch Error {
            ; Fallback to original detection system
            this.fallbackActive := true
            this.UpdateMetrics("fallback_used")
            return this.OriginalDetect(text)
        }
    }
    
    ; Handle uncertain results
    HandleUncertainResult(text) {
        ; Try with context from previous detection
        if (this.detectionCache.Size > 0) {
            ; Use most recent detection as context
            recentKeys := this.detectionCache.Keys
            for key in recentKeys {
                contextLang := this.detectionCache[key]
                result := DetectLanguage(text, contextLang)
                if (result != "UNCERTAIN") {
                    return result
                }
            }
        }
        
        ; Use original detection without context as last resort
        return this.OriginalDetect(text)
    }
    
    ; Original detection system as fallback
    OriginalDetect(text) {
        frenchScore := 0
        englishScore := 0
        
        CalculateLanguageScores(text, &frenchScore, &englishScore)
        
        ; Original threshold logic (pre-Phase 1)
        if (englishScore > frenchScore && (englishScore - frenchScore) >= 2) {
            return "EN"
        } else if (frenchScore > englishScore && (frenchScore - englishScore) >= 1) {
            return "FR"
        } else {
            ; Use pattern-based detection
            if (RegExMatch(text, "i)the\s|and\s|of\s|to\s|in\s|is\s|are\s|that\s|it\s|for\s|with\s")) {
                return "EN"
            } else {
                return "FR" ; Default to French
            }
        }
    }
    
    ; Get confidence score for a detection
    GetConfidence(text, language) {
        return GetLanguageConfidence(text, language)
    }
    
    ; Performance and metrics
    UpdateMetrics(metricType, value := 0) {
        if (!this.performanceMetrics.Has(metricType)) {
            this.performanceMetrics[metricType] := 0
        }
        
        if (metricType == "detection_time") {
            this.performanceMetrics[metricType] := value
        } else {
            this.performanceMetrics[metricType]++
        }
    }
    
    GetMetrics() {
        return this.performanceMetrics
    }
    
    ; Clear cache (for memory management)
    ClearCache() {
        this.detectionCache.Clear()
    }
    
    ; Get cache statistics
    GetCacheStats() {
        return {
            size: this.detectionCache.Size,
            keys: this.detectionCache.Keys
        }
    }
    
    ; Health check for the detection system
    HealthCheck() {
        issues := []
        
        ; Check if fallback is being used frequently
        if (this.fallbackActive && this.performanceMetrics.Has("fallback_used")) {
            fallbackRate := this.performanceMetrics["fallback_used"] / 
                          (this.performanceMetrics.Has("cache_hit") ? this.performanceMetrics["cache_hit"] : 1) * 100
            if (fallbackRate > 10) {
                issues.Push("High fallback rate: " Round(fallbackRate, 1) "%")
            }
        }
        
        ; Check cache efficiency
        if (this.detectionCache.Size > 1000) {
            issues.Push("Large cache size: " this.detectionCache.Size " entries")
        }
        
        return {
            healthy: issues.Length == 0,
            issues: issues,
            metrics: this.performanceMetrics
        }
    }
}

; Convenience functions for integration
EnhancedDetectLanguage(text) {
    return EnhancedLanguageDetector.Detect(text)
}

GetEnhancedLanguageConfidence(text, language := "") {
    if (language == "") {
        language := EnhancedDetectLanguage(text)
    }
    return EnhancedLanguageDetector.GetConfidence(text, language)
}

; Integration with existing VoiceManager
UpdateVoiceSelection(text) {
    language := EnhancedDetectLanguage(text)
    confidence := GetEnhancedLanguageConfidence(text, language)
    
    ; Only switch voice if confidence is high enough
    if (confidence >= 0.7) {
        if (language == "EN" && currentLanguage != "EN") {
            ; Switch to English voice
            SetEnglishVoice()
            currentLanguage := "EN"
        } else if (language == "FR" && currentLanguage != "FR") {
            ; Switch to French voice
            SetFrenchVoice()
            currentLanguage := "FR"
        }
    }
    
    return {language: language, confidence: confidence}
}