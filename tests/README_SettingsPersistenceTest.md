# Settings Persistence Test Documentation

## Overview
This comprehensive test suite verifies that the TTS application settings persistence is working correctly after the implemented fixes. The test validates that all user preferences are properly saved and restored between application sessions.

## Test File
- **Location**: `tests/SettingsPersistenceTest.ahk`
- **Purpose**: Comprehensive validation of settings persistence functionality

## Test Scenarios Covered

### 1. GUI Position Persistence
- Validates that window position (X, Y coordinates) is saved and restored correctly
- Tests multiple position scenarios to ensure robustness

### 2. Voice Settings Persistence
- Verifies SelectedVoiceEN and SelectedVoiceFR settings are preserved
- Tests multiple voice combinations

### 3. Language Mode Persistence
- Validates LanguageMode setting (AUTO, EN, FR) persistence
- Ensures language detection preferences are maintained

### 4. Speed and Volume Persistence
- Tests Speed setting preservation (-10 to +10 range)
- Validates Volume setting persistence (0-100 range)
- Verifies proper numeric value handling

### 5. Start Minimized Setting Persistence
- Validates StartMinimized boolean setting
- Tests both true and false states
- Critical fix validation (this was previously missing)

### 6. Auto-save on GUI Movement
- Simulates GUI dragging and position changes
- Verifies auto-save functionality during window movement
- Tests multiple position scenarios

### 7. Auto-save on Application Exit
- Validates that all settings are saved when application closes
- Simulates the SaveSettingsOnExit function behavior

### 8. Settings File Content Verification
- Ensures settings file structure is correct
- Validates all expected keys exist
- Provides file content inspection for manual verification

### 9. Real-world Usage Simulation
- Simulates complete user session with multiple setting changes
- Tests realistic usage patterns
- Validates sequential setting modifications

### 10. Settings Reset and Recovery
- Tests recovery from missing settings file
- Validates default value fallback
- Tests recovery from corrupted settings file

## How to Run the Test

### Method 1: Direct Execution
1. Open AutoHotkey v2
2. Load the test file: `tests/SettingsPersistenceTest.ahk`
3. Uncomment the last line: `SettingsPersistenceTestMain()`
4. Run the script

### Method 2: Manual Launch
1. In the test file, locate the comment at the bottom:
   ```ahk
   ; Uncomment the line below to run the test
   ; SettingsPersistenceTestMain()
   ```
2. Remove the semicolon to activate the test
3. Run the script

### Method 3: Script Inclusion
You can include the test in another script:
```ahk
#Include "tests/SettingsPersistenceTest.ahk"
; Then call: SettingsPersistenceTestMain()
```

## Expected Output

### Console Output
The test will provide detailed console output showing:
- Test progress and status
- Individual test results (✓ PASS or ✗ FAIL)
- Error messages and debugging information
- Final summary with success rate

### Log File
- **Location**: `SettingsPersistenceTest.log` (in script directory)
- **Content**: Timestamped detailed log of all test operations
- **Purpose**: Persistent log for later analysis

### Message Box
Final summary dialog showing:
- Total number of tests executed
- Number of passed tests
- Number of failed tests
- Success percentage

## Test Results Interpretation

### Success Criteria
- **All tests should PASS** for settings persistence to be considered working correctly
- Success rate should be 100%
- No critical errors should occur during execution

### Failure Analysis
If any test fails, check:
1. **Settings file permissions**: Ensure write access to application directory
2. **File corruption**: Check if settingsTTS.ini is corrupted
3. **Code implementation**: Verify VoiceManager.ahk SaveVoiceSettings function
4. **Directory structure**: Ensure proper file paths

### Common Issues and Solutions

#### Settings File Not Found
- **Issue**: Test cannot locate settingsTTS.ini
- **Solution**: Check if TTS application has been run at least once to create the file

#### Permission Denied
- **Issue**: Cannot write to settings file
- **Solution**: Run as administrator or check directory permissions

#### Unexpected Values
- **Issue**: Settings values don't match expected values
- **Solution**: Review SaveVoiceSettings and LoadVoiceSettings functions in VoiceManager.ahk

## Validation of Fixes

This test specifically validates the following fixes:

### 1. Start Minimized Setting Bug Fix
- **Before**: StartMinimized setting was not saved/loaded
- **After**: StartMinimized setting is properly persisted
- **Test**: `TestStartMinimizedPersistence()` validates this fix

### 2. GUI Position Persistence
- **Before**: GUI position was not saved correctly
- **After**: Position is saved during drag operations and on exit
- **Test**: `TestGuiPositionPersistence()` validates this fix

### 3. Auto-save Functionality
- **Before**: Settings were only saved on explicit exit
- **After**: Settings are auto-saved during GUI movement and parameter changes
- **Test**: `TestAutoSaveOnGuiMovement()` validates this fix

## Integration with Development Workflow

### Before Deployment
Run this test before releasing new versions to ensure settings persistence works correctly.

### After Bug Fixes
Execute the test whenever settings-related bugs are fixed to validate the solution.

### Continuous Integration
Consider integrating this test into automated testing pipelines for regression testing.

## Code Comments Standard
All code comments in this test file follow the project standard of using English only, as specified in the project requirements.

## File Safety
- The test automatically backs up existing settings before running
- Original settings are restored after test completion
- Test settings file is cleaned up after execution
- No permanent changes are made to user's actual settings

## Technical Details

### Constants Used
- `TEST_LOG_FILE`: Log file location
- `SETTINGS_FILE`: TTS settings file path
- `BACKUP_SETTINGS_FILE`: Backup file for original settings
- `TTS_SCRIPT_PATH`: Path to main TTS script

### Dependencies
- AutoHotkey v2.0
- File system access for settings file operations
- INI file reading/writing capabilities

### Error Handling
- Comprehensive try-catch blocks for each test
- Graceful handling of file access errors
- Detailed error logging for debugging
- Safe cleanup even if tests fail

This test suite provides complete validation that the settings persistence implementation is working correctly and all previously identified issues have been resolved.