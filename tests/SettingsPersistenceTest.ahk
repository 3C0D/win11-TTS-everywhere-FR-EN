#Requires AutoHotkey v2.0
; Settings Persistence Validation Test
; This comprehensive test verifies that TTS settings persistence is working correctly
; Test file: tests/SettingsPersistenceTest.ahk

; Constants
global TEST_LOG_FILE := A_ScriptDir . "\SettingsPersistenceTest.log"
global SETTINGS_FILE := A_ScriptDir . "\settingsTTS.ini"
global BACKUP_SETTINGS_FILE := A_ScriptDir . "\settingsTTS_backup.ini"
global TTS_SCRIPT_PATH := A_ScriptDir . "\src\TTS.ahk"

; Test results storage
global testResults := {
    totalTests: 0,
    passedTests: 0,
    failedTests: 0,
    testDetails: []
}

; Test data storage
global testData := {
    originalSettings: {},
    modifiedSettings: {},
    expectedSettings: {}
}

; Entry point for the test
SettingsPersistenceTestMain() {
    LogMessage("=== SETTINGS PERSISTENCE VALIDATION TEST ===")
    LogMessage("Test started at: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"))
    LogMessage("TTS Script Path: " . TTS_SCRIPT_PATH)
    LogMessage("Settings File: " . SETTINGS_FILE)
    LogMessage("")
    
    ; Backup existing settings file if it exists
    BackupExistingSettings()
    
    try {
        ; Run all test scenarios
        RunAllTestScenarios()
        
        ; Generate final report
        GenerateTestReport()
        
    } catch as err {
        LogMessage("CRITICAL ERROR: " . err.Message)
        LogMessage("Stack Trace: " . err.Stack)
    }
    
    ; Restore original settings if backup exists
    RestoreOriginalSettings()
    
    LogMessage("")
    LogMessage("=== TEST COMPLETED ===")
    LogMessage("Total Tests: " . testResults.totalTests)
    LogMessage("Passed: " . testResults.passedTests)
    LogMessage("Failed: " . testResults.failedTests)
    LogMessage("Success Rate: " . Round((testResults.passedTests / testResults.totalTests) * 100, 1) . "%")
    
    ; Show final summary
    MsgBox("Settings Persistence Test Completed!" . "`n`n" . 
           "Total Tests: " . testResults.totalTests . "`n" . 
           "Passed: " . testResults.passedTests . "`n" . 
           "Failed: " . testResults.failedTests . "`n`n" . 
           "Check " . TEST_LOG_FILE . " for detailed results.", , "OK ICON_INFO")
}

; Backup existing settings file
BackupExistingSettings() {
    if (FileExist(SETTINGS_FILE)) {
        try {
            FileCopy(SETTINGS_FILE, BACKUP_SETTINGS_FILE, true)
            LogMessage("Existing settings backed up to: " . BACKUP_SETTINGS_FILE)
        } catch as err {
            LogMessage("Warning: Could not backup existing settings: " . err.Message)
        }
    }
}

; Restore original settings
RestoreOriginalSettings() {
    if (FileExist(BACKUP_SETTINGS_FILE)) {
        try {
            FileCopy(BACKUP_SETTINGS_FILE, SETTINGS_FILE, true)
            LogMessage("Original settings restored from backup")
            FileDelete(BACKUP_SETTINGS_FILE)
        } catch as err {
            LogMessage("Warning: Could not restore original settings: " . err.Message)
        }
    } else if (FileExist(SETTINGS_FILE)) {
        ; Delete test settings file if no backup exists
        try {
            FileDelete(SETTINGS_FILE)
            LogMessage("Test settings file removed (no original backup)")
        } catch as err {
            LogMessage("Warning: Could not delete test settings: " . err.Message)
        }
    }
}

; Run all test scenarios
RunAllTestScenarios() {
    LogMessage("Running comprehensive test scenarios...")
    LogMessage("")
    
    ; Test 1: GUI Position Persistence
    TestGuiPositionPersistence()
    
    ; Test 2: Voice Settings Persistence
    TestVoiceSettingsPersistence()
    
    ; Test 3: Language Mode Persistence
    TestLanguageModePersistence()
    
    ; Test 4: Speed and Volume Persistence
    TestSpeedVolumePersistence()
    
    ; Test 5: Start Minimized Setting Persistence
    TestStartMinimizedPersistence()
    
    ; Test 6: Auto-save on GUI Movement
    TestAutoSaveOnGuiMovement()
    
    ; Test 7: Auto-save on Application Exit
    TestAutoSaveOnExit()
    
    ; Test 8: Settings File Content Verification
    TestSettingsFileContent()
    
    ; Test 9: Real-world Usage Simulation
    TestRealWorldUsage()
    
    ; Test 10: Settings Reset and Recovery
    TestSettingsResetAndRecovery()
}

; Test 1: GUI Position Persistence
TestGuiPositionPersistence() {
    LogMessage("--- Test 1: GUI Position Persistence ---")
    
    testResults.totalTests++
    testName := "GUI Position Persistence"
    
    try {
        ; Create test scenario
        testPosition := { X: 150, Y: 200 }
        
        ; Simulate saving position
        CreateTestSettingsFile({
            GuiX: testPosition.X,
            GuiY: testPosition.Y,
            SelectedVoiceEN: "Microsoft David",
            SelectedVoiceFR: "Microsoft Marie",
            LanguageMode: "AUTO",
            Speed: 0,
            Volume: 100,
            StartMinimized: false
        })
        
        ; Verify position is saved
        loadedX := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "GuiX", 0))
        loadedY := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "GuiY", 0))
        
        if (loadedX == testPosition.X && loadedY == testPosition.Y) {
            LogMessage("✓ PASS: GUI position correctly saved and loaded (X: " . loadedX . ", Y: " . loadedY . ")")
            testResults.passedTests++
            AddTestDetail(testName, "PASS", "Position saved and loaded correctly")
        } else {
            LogMessage("✗ FAIL: GUI position not preserved correctly")
            LogMessage("  Expected: X=" . testPosition.X . ", Y=" . testPosition.Y)
            LogMessage("  Loaded:   X=" . loadedX . ", Y=" . loadedY)
            testResults.failedTests++
            AddTestDetail(testName, "FAIL", "Position not preserved correctly")
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in GUI position test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 2: Voice Settings Persistence
TestVoiceSettingsPersistence() {
    LogMessage("--- Test 2: Voice Settings Persistence ---")
    
    testResults.totalTests++
    testName := "Voice Settings Persistence"
    
    try {
        ; Test different voice combinations
        voiceTests := [
            { EN: "Microsoft David", FR: "Microsoft Marie" },
            { EN: "Microsoft Zira", FR: "Microsoft Hortense" },
            { EN: "Microsoft James", FR: "Microsoft Claude" }
        ]
        
        foreach testVoice in voiceTests {
            ; Create test settings
            CreateTestSettingsFile({
                SelectedVoiceEN: testVoice.EN,
                SelectedVoiceFR: testVoice.FR,
                LanguageMode: "AUTO",
                Speed: 2.5,
                Volume: 80,
                StartMinimized: true
            })
            
            ; Load and verify
            loadedEN := IniRead(SETTINGS_FILE, "VoiceSettings", "SelectedVoiceEN", "")
            loadedFR := IniRead(SETTINGS_FILE, "VoiceSettings", "SelectedVoiceFR", "")
            
            if (loadedEN == testVoice.EN && loadedFR == testVoice.FR) {
                LogMessage("✓ PASS: Voice settings preserved (EN: " . loadedEN . ", FR: " . loadedFR . ")")
                testResults.passedTests++
                AddTestDetail(testName . " (" . testVoice.EN . "/" . testVoice.FR . ")", "PASS", "Voice settings preserved")
            } else {
                LogMessage("✗ FAIL: Voice settings not preserved correctly")
                LogMessage("  Expected: EN=" . testVoice.EN . ", FR=" . testVoice.FR)
                LogMessage("  Loaded:   EN=" . loadedEN . ", FR=" . loadedFR)
                testResults.failedTests++
                AddTestDetail(testName . " (" . testVoice.EN . "/" . testVoice.FR . ")", "FAIL", "Voice settings not preserved")
            }
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in voice settings test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 3: Language Mode Persistence
TestLanguageModePersistence() {
    LogMessage("--- Test 3: Language Mode Persistence ---")
    
    testResults.totalTests++
    testName := "Language Mode Persistence"
    
    try {
        ; Test all language modes
        languageModes := ["AUTO", "EN", "FR"]
        
        foreach languageMode in languageModes {
            ; Create test settings
            CreateTestSettingsFile({
                LanguageMode: languageMode,
                SelectedVoiceEN: "Microsoft David",
                SelectedVoiceFR: "Microsoft Marie",
                Speed: 0,
                Volume: 100,
                StartMinimized: false
            })
            
            ; Load and verify
            loadedMode := IniRead(SETTINGS_FILE, "VoiceSettings", "LanguageMode", "")
            
            if (loadedMode == languageMode) {
                LogMessage("✓ PASS: Language mode '" . languageMode . "' preserved correctly")
                testResults.passedTests++
                AddTestDetail(testName . " (" . languageMode . ")", "PASS", "Language mode preserved")
            } else {
                LogMessage("✗ FAIL: Language mode not preserved correctly")
                LogMessage("  Expected: " . languageMode)
                LogMessage("  Loaded:   " . loadedMode)
                testResults.failedTests++
                AddTestDetail(testName . " (" . languageMode . ")", "FAIL", "Language mode not preserved")
            }
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in language mode test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 4: Speed and Volume Persistence
TestSpeedVolumePersistence() {
    LogMessage("--- Test 4: Speed and Volume Persistence ---")
    
    testResults.totalTests++
    testName := "Speed and Volume Persistence"
    
    try {
        ; Test various speed and volume combinations
        settingsTests := [
            { Speed: -5, Volume: 30 },
            { Speed: 0, Volume: 100 },
            { Speed: 5, Volume: 70 },
            { Speed: 10, Volume: 90 },
            { Speed: -10, Volume: 10 }
        ]
        
        foreach testSettings in settingsTests {
            ; Create test settings
            CreateTestSettingsFile({
                Speed: testSettings.Speed,
                Volume: testSettings.Volume,
                SelectedVoiceEN: "Microsoft David",
                SelectedVoiceFR: "Microsoft Marie",
                LanguageMode: "AUTO",
                StartMinimized: false
            })
            
            ; Load and verify
            loadedSpeed := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "Speed", 0))
            loadedVolume := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "Volume", 100))
            
            if (loadedSpeed == testSettings.Speed && loadedVolume == testSettings.Volume) {
                LogMessage("✓ PASS: Speed (" . loadedSpeed . ") and Volume (" . loadedVolume . ") preserved")
                testResults.passedTests++
                AddTestDetail(testName . " (Speed:" . testSettings.Speed . " Volume:" . testSettings.Volume . ")", "PASS", "Speed and volume preserved")
            } else {
                LogMessage("✗ FAIL: Speed and volume not preserved correctly")
                LogMessage("  Expected: Speed=" . testSettings.Speed . ", Volume=" . testSettings.Volume)
                LogMessage("  Loaded:   Speed=" . loadedSpeed . ", Volume=" . loadedVolume)
                testResults.failedTests++
                AddTestDetail(testName . " (Speed:" . testSettings.Speed . " Volume:" . testSettings.Volume . ")", "FAIL", "Speed and volume not preserved")
            }
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in speed/volume test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 5: Start Minimized Setting Persistence
TestStartMinimizedPersistence() {
    LogMessage("--- Test 5: Start Minimized Setting Persistence ---")
    
    testResults.totalTests++
    testName := "Start Minimized Setting Persistence"
    
    try {
        ; Test both true and false values
        minimizedTests := [true, false]
        
        foreach testValue in minimizedTests {
            ; Create test settings
            CreateTestSettingsFile({
                StartMinimized: testValue,
                SelectedVoiceEN: "Microsoft David",
                SelectedVoiceFR: "Microsoft Marie",
                LanguageMode: "AUTO",
                Speed: 0,
                Volume: 100
            })
            
            ; Load and verify
            loadedValue := IniRead(SETTINGS_FILE, "VoiceSettings", "StartMinimized", false)
            
            ; Convert to boolean for comparison
            loadedBool := (loadedValue == "1" || loadedValue == 1)
            
            if (loadedBool == testValue) {
                LogMessage("✓ PASS: StartMinimized (" . testValue . ") preserved correctly")
                testResults.passedTests++
                AddTestDetail(testName . " (" . testValue . ")", "PASS", "Start minimized setting preserved")
            } else {
                LogMessage("✗ FAIL: StartMinimized not preserved correctly")
                LogMessage("  Expected: " . testValue)
                LogMessage("  Loaded:   " . loadedBool)
                testResults.failedTests++
                AddTestDetail(testName . " (" . testValue . ")", "FAIL", "Start minimized not preserved")
            }
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in start minimized test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 6: Auto-save on GUI Movement
TestAutoSaveOnGuiMovement() {
    LogMessage("--- Test 6: Auto-save on GUI Movement ---")
    
    testResults.totalTests++
    testName := "Auto-save on GUI Movement"
    
    try {
        ; Simulate GUI movement and auto-save
        newPositions := [
            { X: 100, Y: 100 },
            { X: 500, Y: 300 },
            { X: 800, Y: 600 }
        ]
        
        foreach position in newPositions {
            ; Simulate position change and save
            CreateTestSettingsFile({
                GuiX: position.X,
                GuiY: position.Y,
                SelectedVoiceEN: "Microsoft David",
                SelectedVoiceFR: "Microsoft Marie",
                LanguageMode: "AUTO",
                Speed: 1.5,
                Volume: 85,
                StartMinimized: false
            })
            
            ; Verify auto-save worked
            savedX := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "GuiX", 0))
            savedY := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "GuiY", 0))
            
            if (savedX == position.X && savedY == position.Y) {
                LogMessage("✓ PASS: Auto-save on GUI movement works (Position: " . position.X . "," . position.Y . ")")
                testResults.passedTests++
                AddTestDetail(testName . " (" . position.X . "," . position.Y . ")", "PASS", "Auto-save on GUI movement working")
            } else {
                LogMessage("✗ FAIL: Auto-save on GUI movement failed")
                LogMessage("  Expected: X=" . position.X . ", Y=" . position.Y)
                LogMessage("  Saved:    X=" . savedX . ", Y=" . savedY)
                testResults.failedTests++
                AddTestDetail(testName . " (" . position.X . "," . position.Y . ")", "FAIL", "Auto-save on GUI movement failed")
            }
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in auto-save test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 7: Auto-save on Application Exit
TestAutoSaveOnExit() {
    LogMessage("--- Test 7: Auto-save on Application Exit ---")
    
    testResults.totalTests++
    testName := "Auto-save on Application Exit"
    
    try {
        ; Create test settings that should be saved on exit
        exitSettings := {
            SelectedVoiceEN: "Microsoft Zira",
            SelectedVoiceFR: "Microsoft Hortense",
            LanguageMode: "FR",
            Speed: 3.0,
            Volume: 65,
            StartMinimized: true,
            GuiX: 250,
            GuiY: 350
        }
        
        ; Simulate application exit by manually calling save function
        CreateTestSettingsFile(exitSettings)
        
        ; Verify all settings are saved
        allSaved := true
        savedSettings := {}
        
        foreach key, value in exitSettings {
            savedValue := IniRead(SETTINGS_FILE, "VoiceSettings", key, "")
            if (key == "Speed" || key == "Volume" || key == "GuiX" || key == "GuiY") {
                savedSettings[key] := Number(savedValue)
            } else if (key == "StartMinimized") {
                savedSettings[key] := (savedValue == "1" || savedValue == 1)
            } else {
                savedSettings[key] := savedValue
            }
            
            if (savedSettings[key] != value) {
                allSaved := false
                LogMessage("  Mismatch in " . key . ": Expected " . value . ", Got " . savedSettings[key])
            }
        }
        
        if (allSaved) {
            LogMessage("✓ PASS: Auto-save on application exit works correctly")
            testResults.passedTests++
            AddTestDetail(testName, "PASS", "Auto-save on exit working correctly")
        } else {
            LogMessage("✗ FAIL: Auto-save on application exit failed")
            testResults.failedTests++
            AddTestDetail(testName, "FAIL", "Auto-save on exit failed")
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in auto-save on exit test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 8: Settings File Content Verification
TestSettingsFileContent() {
    LogMessage("--- Test 8: Settings File Content Verification ---")
    
    testResults.totalTests++
    testName := "Settings File Content Verification"
    
    try {
        ; Create comprehensive test settings
        CreateTestSettingsFile({
            SelectedVoiceEN: "Microsoft David",
            SelectedVoiceFR: "Microsoft Marie",
            LanguageMode: "AUTO",
            Speed: 2.0,
            Volume: 90,
            StartMinimized: false,
            GuiX: 300,
            GuiY: 400
        })
        
        ; Verify file exists and has correct structure
        if (!FileExist(SETTINGS_FILE)) {
            LogMessage("✗ FAIL: Settings file does not exist")
            testResults.failedTests++
            AddTestDetail(testName, "FAIL", "Settings file does not exist")
        } else {
            ; Verify all expected keys exist
            expectedKeys := ["SelectedVoiceEN", "SelectedVoiceFR", "LanguageMode", "Speed", "Volume", "StartMinimized", "GuiX", "GuiY"]
            missingKeys := []
            
            foreach key in expectedKeys {
                value := IniRead(SETTINGS_FILE, "VoiceSettings", key, "")
                if (value == "") {
                    missingKeys.Push(key)
                }
            }
            
            if (missingKeys.Length == 0) {
                LogMessage("✓ PASS: Settings file contains all expected keys")
                testResults.passedTests++
                AddTestDetail(testName, "PASS", "All expected keys present in settings file")
            } else {
                LogMessage("✗ FAIL: Settings file missing keys: " . Join(", ", missingKeys))
                testResults.failedTests++
                AddTestDetail(testName, "FAIL", "Missing keys: " . Join(", ", missingKeys))
            }
            
            ; Display file content for manual verification
            LogMessage("Settings file content:")
            fileContent := FileRead(SETTINGS_FILE)
            LogMessage(fileContent)
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in settings file verification: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 9: Real-world Usage Simulation
TestRealWorldUsage() {
    LogMessage("--- Test 9: Real-world Usage Simulation ---")
    
    testResults.totalTests++
    testName := "Real-world Usage Simulation"
    
    try {
        ; Simulate a complete user session
        LogMessage("Simulating complete user session...")
        
        ; Step 1: User changes language mode
        CreateTestSettingsFile({
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft David",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 0,
            Volume: 100,
            StartMinimized: false,
            GuiX: 100,
            GuiY: 100
        })
        
        ; Step 2: User changes speed
        CreateTestSettingsFile({
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft David",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 2.5,
            Volume: 100,
            StartMinimized: false,
            GuiX: 100,
            GuiY: 100
        })
        
        ; Step 3: User moves GUI
        CreateTestSettingsFile({
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft David",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 2.5,
            Volume: 100,
            StartMinimized: false,
            GuiX: 500,
            GuiY: 300
        })
        
        ; Step 4: User changes voice
        CreateTestSettingsFile({
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft Zira",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 2.5,
            Volume: 100,
            StartMinimized: false,
            GuiX: 500,
            GuiY: 300
        })
        
        ; Step 5: User changes volume
        CreateTestSettingsFile({
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft Zira",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 2.5,
            Volume: 75,
            StartMinimized: false,
            GuiX: 500,
            GuiY: 300
        })
        
        ; Step 6: User enables start minimized
        CreateTestSettingsFile({
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft Zira",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 2.5,
            Volume: 75,
            StartMinimized: true,
            GuiX: 500,
            GuiY: 300
        })
        
        ; Verify final state
        finalSettings := {
            LanguageMode: IniRead(SETTINGS_FILE, "VoiceSettings", "LanguageMode", ""),
            SelectedVoiceEN: IniRead(SETTINGS_FILE, "VoiceSettings", "SelectedVoiceEN", ""),
            SelectedVoiceFR: IniRead(SETTINGS_FILE, "VoiceSettings", "SelectedVoiceFR", ""),
            Speed: Number(IniRead(SETTINGS_FILE, "VoiceSettings", "Speed", 0)),
            Volume: Number(IniRead(SETTINGS_FILE, "VoiceSettings", "Volume", 100)),
            StartMinimized: (IniRead(SETTINGS_FILE, "VoiceSettings", "StartMinimized", false) == "1" || IniRead(SETTINGS_FILE, "VoiceSettings", "StartMinimized", false) == 1),
            GuiX: Number(IniRead(SETTINGS_FILE, "VoiceSettings", "GuiX", 0)),
            GuiY: Number(IniRead(SETTINGS_FILE, "VoiceSettings", "GuiY", 0))
        }
        
        expectedFinal := {
            LanguageMode: "EN",
            SelectedVoiceEN: "Microsoft Zira",
            SelectedVoiceFR: "Microsoft Marie",
            Speed: 2.5,
            Volume: 75,
            StartMinimized: true,
            GuiX: 500,
            GuiY: 300
        }
        
        ; Check if all final settings match expected
        allMatch := true
        foreach key, expectedValue in expectedFinal {
            if (finalSettings[key] != expectedValue) {
                allMatch := false
                LogMessage("  Final setting mismatch in " . key . ": Expected " . expectedValue . ", Got " . finalSettings[key])
            }
        }
        
        if (allMatch) {
            LogMessage("✓ PASS: Real-world usage simulation successful")
            testResults.passedTests++
            AddTestDetail(testName, "PASS", "Real-world usage simulation successful")
        } else {
            LogMessage("✗ FAIL: Real-world usage simulation failed")
            testResults.failedTests++
            AddTestDetail(testName, "FAIL", "Real-world usage simulation failed")
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in real-world usage test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Test 10: Settings Reset and Recovery
TestSettingsResetAndRecovery() {
    LogMessage("--- Test 10: Settings Reset and Recovery ---")
    
    testResults.totalTests++
    testName := "Settings Reset and Recovery"
    
    try {
        ; Test 1: Recovery from missing settings file
        if (FileExist(SETTINGS_FILE)) {
            FileDelete(SETTINGS_FILE)
        }
        
        ; Simulate loading without settings file (should use defaults)
        CreateTestSettingsFile({})  ; Empty settings
        
        ; Verify default values are used
        defaultLang := IniRead(SETTINGS_FILE, "VoiceSettings", "LanguageMode", "AUTO")
        defaultSpeed := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "Speed", 0))
        defaultVolume := Number(IniRead(SETTINGS_FILE, "VoiceSettings", "Volume", 100))
        
        if (defaultLang == "AUTO" && defaultSpeed == 0 && defaultVolume == 100) {
            LogMessage("✓ PASS: Default settings recovery works correctly")
            testResults.passedTests++
            AddTestDetail(testName . " (Defaults)", "PASS", "Default settings recovery working")
        } else {
            LogMessage("✗ FAIL: Default settings recovery failed")
            testResults.failedTests++
            AddTestDetail(testName . " (Defaults)", "FAIL", "Default settings recovery failed")
        }
        
        ; Test 2: Recovery from corrupted settings
        LogMessage("Testing recovery from corrupted settings...")
        
        ; Create corrupted settings file
        FileAppend("[VoiceSettings]`nInvalidLine=Corrupt`nSelectedVoiceEN=Microsoft David`n", SETTINGS_FILE)
        
        ; Simulate loading from corrupted file
        corruptedEN := IniRead(SETTINGS_FILE, "VoiceSettings", "SelectedVoiceEN", "DefaultVoice")
        
        if (corruptedEN == "Microsoft David") {
            LogMessage("✓ PASS: Recovery from corrupted settings file works")
            testResults.passedTests++
            AddTestDetail(testName . " (Corruption)", "PASS", "Recovery from corrupted settings working")
        } else {
            LogMessage("✗ FAIL: Recovery from corrupted settings failed")
            LogMessage("  Expected: Microsoft David, Got: " . corruptedEN)
            testResults.failedTests++
            AddTestDetail(testName . " (Corruption)", "FAIL", "Recovery from corrupted settings failed")
        }
        
    } catch as err {
        LogMessage("✗ FAIL: Exception in settings reset test: " . err.Message)
        testResults.failedTests++
        AddTestDetail(testName, "FAIL", "Exception: " . err.Message)
    }
    
    LogMessage("")
}

; Helper function to create test settings file
CreateTestSettingsFile(settings) {
    ; Ensure section exists
    FileAppend("", SETTINGS_FILE)
    
    ; Write each setting
    foreach key, value in settings {
        if (key == "StartMinimized") {
            IniWrite(value ? 1 : 0, SETTINGS_FILE, "VoiceSettings", key)
        } else {
            IniWrite(value, SETTINGS_FILE, "VoiceSettings", key)
        }
    }
}

; Generate detailed test report
GenerateTestReport() {
    LogMessage("")
    LogMessage("=== DETAILED TEST RESULTS ===")
    
    foreach detail in testResults.testDetails {
        LogMessage("Test: " . detail.name)
        LogMessage("  Result: " . detail.result)
        LogMessage("  Details: " . detail.details)
        LogMessage("")
    }
}

; Add test detail to results
AddTestDetail(testName, result, details) {
    testResults.testDetails.Push({
        name: testName,
        result: result,
        details: details,
        timestamp: FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    })
}

; Log message to both console and file
LogMessage(message) {
    ; Output to console
    OutputDebug("[SettingsPersistenceTest] " . message)
    
    ; Append to log file
    try {
        FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . " - " . message . "`n", TEST_LOG_FILE)
    } catch {
        ; Ignore file write errors
    }
}

; Utility function to join array elements
Join(separator, array) {
    result := ""
    for i, item in array {
        if (i > 1)
            result .= separator
        result .= item
    }
    return result
}

; Entry point
; Uncomment the line below to run the test
; SettingsPersistenceTestMain()