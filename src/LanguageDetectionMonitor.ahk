#Requires AutoHotkey v2.0

; Language Detection Monitoring and Metrics System
; Phase 1: Performance tracking and health monitoring

class LanguageDetectionMonitor {
    static metrics := {
        total_detections: 0,
        successful_detections: 0,
        failed_detections: 0,
        fallback_usage: 0,
        cache_hits: 0,
        cache_misses: 0,
        total_processing_time: 0,
        avg_processing_time: 0,
        fr_detections: 0,
        en_detections: 0,
        uncertain_detections: 0,
        high_confidence: 0,
        medium_confidence: 0,
        low_confidence: 0
    }
    
    static session_start := A_Now
    static alerts := []
    static config := {}
    
    ; Initialize monitoring system
    static Init() {
        this.LoadConfiguration()
        this.StartSession()
    }
    
    ; Load configuration from JSON file
    static LoadConfiguration() {
        try {
            configFile := FileRead("config/LanguageConfig.json")
            this.config := JSON.parse(configFile)
        } catch Error {
            ; Use default configuration
            this.config := this.GetDefaultConfig()
        }
    }
    
    ; Get default configuration
    static GetDefaultConfig() {
        return {
            "language_detection": {
                "monitoring": {
                    "alert_thresholds": {
                        "fallback_rate": 10,
                        "cache_size": 1000,
                        "detection_time": 10,
                        "accuracy_drop": 5
                    }
                },
                "performance_targets": {
                    "average_detection_time": "<= 5ms",
                    "fallback_rate": "<= 5%"
                }
            }
        }
    }
    
    ; Start new monitoring session
    static StartSession() {
        this.session_start := A_Now
        this.alerts := []
        this.ResetCounters()
    }
    
    ; Reset all counters
    static ResetCounters() {
        for key in this.metrics.OwnKeys() {
            this.metrics[key] := 0
        }
    }
    
    ; Record a detection event
    static RecordDetection(text, result, processing_time, confidence := 0) {
        this.metrics.total_detections++
        this.metrics.total_processing_time += processing_time
        
        ; Update averages
        this.metrics.avg_processing_time := this.metrics.total_processing_time / this.metrics.total_detections
        
        ; Count by result
        if (result == "FR") {
            this.metrics.fr_detections++
        } else if (result == "EN") {
            this.metrics.en_detections++
        } else if (result == "UNCERTAIN") {
            this.metrics.uncertain_detections++
        }
        
        ; Count by confidence level
        if (confidence >= 0.8) {
            this.metrics.high_confidence++
        } else if (confidence >= 0.6) {
            this.metrics.medium_confidence++
        } else {
            this.metrics.low_confidence++
        }
        
        ; Check for alerts
        this.CheckAlerts()
    }
    
    ; Record successful detection
    static RecordSuccess(processing_time := 0, confidence := 0) {
        this.metrics.successful_detections++
        this.RecordDetection("", "SUCCESS", processing_time, confidence)
    }
    
    ; Record failed detection
    static RecordFailure(processing_time := 0) {
        this.metrics.failed_detections++
        this.RecordDetection("", "FAILURE", processing_time, 0)
    }
    
    ; Record fallback usage
    static RecordFallback() {
        this.metrics.fallback_usage++
        this.AddAlert("High fallback usage detected", "warning")
    }
    
    ; Record cache hit/miss
    static RecordCacheHit() {
        this.metrics.cache_hits++
    }
    
    static RecordCacheMiss() {
        this.metrics.cache_misses++
    }
    
    ; Check for alert conditions
    static CheckAlerts() {
        ; Calculate current rates
        accuracy_rate := this.GetAccuracyRate()
        fallback_rate := this.GetFallbackRate()
        cache_hit_ratio := this.GetCacheHitRatio()
        
        ; Check thresholds
        thresholds := this.config.language_detection.monitoring.alert_thresholds
        
        if (fallback_rate > thresholds.fallback_rate) {
            this.AddAlert("Fallback rate too high: " fallback_rate "%", "warning")
        }
        
        if (accuracy_rate < 85) {
            this.AddAlert("Accuracy rate dropped: " accuracy_rate "%", "critical")
        }
        
        if (this.metrics.avg_processing_time > thresholds.detection_time) {
            this.AddAlert("Detection time too slow: " this.metrics.avg_processing_time "ms", "warning")
        }
    }
    
    ; Add alert to list
    static AddAlert(message, severity := "info") {
        alert := {
            message: message,
            severity: severity,
            timestamp: A_Now,
            session_time: this.GetSessionDuration()
        }
        this.alerts.Push(alert)
        
        ; Log alert
        this.LogAlert(alert)
    }
    
    ; Log alert to file
    static LogAlert(alert) {
        log_entry := "[" alert.timestamp "] [" Upper(alert.severity) "] " alert.message
        log_entry .= " (Session: " alert.session_time ")`n"
        
        try {
            FileAppend(log_entry, "logs/language_detection_alerts.log")
        } catch Error {
            ; Silently fail if log file not available
        }
    }
    
    ; Get current metrics
    static GetMetrics() {
        metrics_copy := {}
        for key, value in this.metrics.OwnKeys() {
            metrics_copy[key] := value
        }
        
        ; Add calculated metrics
        metrics_copy.accuracy_rate := this.GetAccuracyRate()
        metrics_copy.fallback_rate := this.GetFallbackRate()
        metrics_copy.cache_hit_ratio := this.GetCacheHitRatio()
        metrics_copy.session_duration := this.GetSessionDuration()
        
        return metrics_copy
    }
    
    ; Get accuracy rate percentage
    static GetAccuracyRate() {
        total := this.metrics.successful_detections + this.metrics.failed_detections
        if (total == 0) return 100
        return Round((this.metrics.successful_detections / total) * 100, 1)
    }
    
    ; Get fallback rate percentage
    static GetFallbackRate() {
        if (this.metrics.total_detections == 0) return 0
        return Round((this.metrics.fallback_usage / this.metrics.total_detections) * 100, 1)
    }
    
    ; Get cache hit ratio percentage
    static GetCacheHitRatio() {
        total_cache_ops := this.metrics.cache_hits + this.metrics.cache_misses
        if (total_cache_ops == 0) return 0
        return Round((this.metrics.cache_hits / total_cache_ops) * 100, 1)
    }
    
    ; Get session duration in minutes
    static GetSessionDuration() {
        return Round((A_Now - this.session_start) / 60000, 1)
    }
    
    ; Generate health report
    static GenerateHealthReport() {
        metrics := this.GetMetrics()
        
        report := "=== LANGUAGE DETECTION HEALTH REPORT ===`n"
        report .= "Generated: " A_Now "`n"
        report .= "Session Duration: " metrics.session_duration " minutes`n`n"
        
        report .= "PERFORMANCE METRICS:`n"
        report .= "- Total Detections: " this.metrics.total_detections "`n"
        report .= "- Accuracy Rate: " metrics.accuracy_rate "%`n"
        report .= "- Avg Processing Time: " metrics.avg_processing_time " ms`n"
        report .= "- Cache Hit Ratio: " metrics.cache_hit_ratio "%`n`n"
        
        report .= "DETECTION BREAKDOWN:`n"
        report .= "- French: " this.metrics.fr_detections " (" Round((this.metrics.fr_detections / this.metrics.total_detections) * 100, 1) "%)`n"
        report .= "- English: " this.metrics.en_detections " (" Round((this.metrics.en_detections / this.metrics.total_detections) * 100, 1) "%)`n"
        report .= "- Uncertain: " this.metrics.uncertain_detections " (" Round((this.metrics.uncertain_detections / this.metrics.total_detections) * 100, 1) "%)`n`n"
        
        report .= "CONFIDENCE LEVELS:`n"
        report .= "- High (>= 0.8): " this.metrics.high_confidence " (" Round((this.metrics.high_confidence / this.metrics.total_detections) * 100, 1) "%)`n"
        report .= "- Medium (0.6-0.8): " this.metrics.medium_confidence " (" Round((this.metrics.medium_confidence / this.metrics.total_detections) * 100, 1) "%)`n"
        report .= "- Low (< 0.6): " this.metrics.low_confidence " (" Round((this.metrics.low_confidence / this.metrics.total_detections) * 100, 1) "%)`n`n"
        
        if (this.alerts.Length > 0) {
            report .= "ACTIVE ALERTS (" this.alerts.Length "):`n"
            for alert in this.alerts {
                report .= "- [" Upper(alert.severity) "] " alert.message "`n"
            }
        } else {
            report .= "SYSTEM STATUS: HEALTHY`n"
        }
        
        report .= "========================================`n"
        
        return report
    }
    
    ; Save metrics to file
    static SaveMetricsToFile(filename := "metrics/language_detection_metrics.json") {
        metrics_data := {
            generated_at: A_Now,
            session_info: {
                start_time: this.session_start,
                duration_minutes: this.GetSessionDuration()
            },
            metrics: this.GetMetrics(),
            alerts: this.alerts
        }
        
        try {
            json_content := JSON.stringify(metrics_data, 4)
            FileAppend(json_content . "`n`n", filename)
            return true
        } catch Error {
            return false
        }
    }
    
    ; Reset monitoring session
    static ResetSession() {
        this.StartSession()
    }
    
    ; Get performance status
    static GetStatus() {
        metrics := this.GetMetrics()
        
        if (metrics.accuracy_rate >= 90 && metrics.avg_processing_time <= 5 && metrics.fallback_rate <= 5) {
            return "EXCELLENT"
        } else if (metrics.accuracy_rate >= 85 && metrics.avg_processing_time <= 10) {
            return "GOOD"
        } else if (metrics.accuracy_rate >= 75) {
            return "WARNING"
        } else {
            return "CRITICAL"
        }
    }
}

; Initialize monitoring on script start
LanguageDetectionMonitor.Init()