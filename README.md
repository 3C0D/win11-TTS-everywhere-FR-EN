# 📢 **IMPORTANT : TTS Voice Installation Required**

**For optimal experience, make sure you have installed the necessary Windows language packs for TTS voices (for example, install English if you are in France).**

**For detailed installation instructions, see the [Voice Installation for Regional Support](#voice-installation-for-regional-support) section below.**

**Pour les utilisateurs francophones :** Veuillez consulter le fichier [README_fr.md](README_fr.md) pour des instructions détaillées et spécifiques à votre langue.

---

A powerful and user-friendly Text-to-Speech application with advanced features including language auto-detection, customizable voices, and intuitive keyboard controls.

# 🗣️ Text-to-Speech Application

A powerful and user-friendly Text-to-Speech application with advanced features including language auto-detection, customizable voices, and intuitive keyboard controls.

## 🚀 Quick Start

1. **Select or copy text** in any application
2. **Press Win+Y** to start reading
3. **Use keyboard shortcuts** or the control panel to manage playback
4. **Customize settings** through the gear icon in the control panel

## ✨ Features

- **🤖 Multi-Language Support**: Automatic detection of English and French text
- **🎵 Voice Customization**: Select different voices for each language
- **⚡ Global Hotkeys**: Control from anywhere without switching windows
- **🎛️ Real-time Controls**: Speed, volume, and playback adjustments on the fly
- **📱 Compact Interface**: Minimizable control panel with drag-and-drop positioning
- **🔧 Persistent Settings**: Your preferences are saved automatically
- **📋 Integrated Help**: Built-in shortcuts reference in the settings panel
- **🆕 Start Minimized Option**: Option to start the control panel minimized

## 🎯 Keyboard Shortcuts

### **Main Controls**
- **Win+Y** - Start/Stop reading selected text
- **Win+Space** - Pause/Resume reading
- **Win+F** - Show/Hide control panel (Full screen toggle)

### **Navigation**
- **Win+N** - Skip to **N**ext paragraph
- **Win+P** - Go to **P**revious paragraph

### **Speed Control**
- **Numpad+** - Increase reading speed
- **Numpad-** - Decrease reading speed

### **Volume Control**
- **Numpad*** - Increase volume
- **Numpad/** - Decrease volume

## 🎛️ Control Panel

The control panel appears automatically when reading starts and includes:

- **∔** - Minimize panel (click the "TTS Running" notification to restore)
- **⮌** - Previous paragraph
- **⏸/▶** - Pause/Resume
- **⏹** - Stop reading
- **⭢** - Next paragraph
- **⚙** - Settings menu

### **Draggable Interface**
- **Drag the top area** of the control panel to reposition it anywhere on your screen
- Position is remembered for next use
- Minimize when you need screen space
- **Notification when minimized**: A small "TTS Running" notification appears in the top-right corner when minimized - click it to restore the panel

## ⚙️ Settings Panel

Access settings through the gear icon (⚙) in the control panel. The settings panel features **three organized tabs**:

### **General Tab**
- **Speed Control**: Adjust reading speed from -10 to +10
- **Volume Control**: Set volume from 0 to 100
- **Language Mode**: Choose Auto-detection, English only, or French only
- **🆕 Start Minimized**: Option to automatically start the control panel minimized when reading begins

### **Voices Tab**
- **English Voices**: Select from available English TTS voices
- **French Voices**: Select from available French TTS voices
- Voice changes apply immediately during reading

### **Shortcuts Tab** ⭐ *New!*
- **Complete Reference**: All keyboard shortcuts in one place
- **Quick Access**: No need to remember shortcuts - they're always available
- **Organized Layout**: Grouped by function (Controls, Navigation, Speed/Volume)

## 🌐 Language Support

### **Automatic Detection**
The application automatically detects the dominant language in your text:
- **English text** → Uses selected English voice
- **French text** → Uses selected French voice
- **Mixed text** → Uses voice based on dominant language

### **Manual Override**
Force a specific language through the settings:
- **Auto** - Automatic detection (default)
- **English** - Always use English voice
- **Français** - Always use French voice

## 🛠️ Advanced Features

### **Paragraph Navigation**
- Text is automatically split into paragraphs
- Skip boring sections with Win+N
- Go back to repeat important parts with Win+P
- Perfect for reading long documents, articles, or books

### **Real-time Adjustments**
- Change speed and volume while reading
- Switch voices on-the-fly
- Visual feedback with temporary overlay windows
- Settings changes are applied instantly

### **Smart Interface Design**
- **Drag Zone**: Only the top area (28px) of the control panel is draggable
- **Button Protection**: Buttons remain fully functional and don't interfere with dragging
- **Auto-positioning**: Settings panel follows the main panel when moved
- **Minimize/Restore**: Clean notification system with proper cleanup

### **Smart Text Processing**
- Handles clipboard and selected text
- Processes various text formats
- Optimized for natural speech patterns

### **🆕 Enhanced Minimization**
- **Start Minimized**: Choose to start reading with the panel already minimized
- **Clean Notification**: The minimized notification properly disappears when reading stops
- **Easy Restore**: Click the notification or use Win+F to restore the panel
- **Automatic Cleanup**: No persistent notifications after reading ends

## 🎭 Use Cases

- **📚 Reading Articles**: Speed through long articles with navigation controls
- **📖 E-books**: Listen to digital books with bookmark-like paragraph jumping
- **📧 Emails**: Quickly listen to important messages
- **📝 Documents**: Proof-read your writing by hearing it
- **🌐 Web Content**: Make any webpage accessible through audio
- **🔍 Research**: Listen to research papers while taking notes
- **🎓 Learning**: Reference shortcuts anytime in the built-in help tab
- **🤫 Discreet Reading**: Use the start minimized option for unobtrusive listening

## 🔧 Technical Requirements

- **Windows 10/11** with SAPI (Speech API) support
- **AutoHotkey v2.0** runtime
- **Available TTS voices** for desired languages

## 🚨 Troubleshooting

### **No Sound**
- Check Windows volume mixer
- Verify TTS voices are installed
- Try adjusting volume with Numpad* and Numpad/

### **Wrong Language**
- Check language detection in settings General tab
- Manually select language if auto-detection fails
- Ensure appropriate language voice is installed in Voices tab

### **Control Panel Issues**
- Use Win+F to toggle panel visibility
- Click "TTS Running" notification to restore minimized panel
- **Drag only the top area** of the panel to reposition it

### **Settings Won't Open/Close**
- Click the gear (⚙) button to toggle settings
- Settings will close automatically when you stop reading
- Use the gear button or close the main panel to close settings

### **Hotkeys Not Working**
- Ensure no other application is using the same shortcuts
- Try running as administrator if needed
- Check Windows accessibility settings
- Refer to the Shortcuts tab in settings for a complete list

### **Voice Installation for Regional Support**
- **Problem**: Certain TTS voices (e.g., specific Mark and David voices) may not be available by default for your region.
- **Solution**: To access a wider range of voices, ensure you have installed the necessary language packs for your region. For example, if you are in France and need specific English voices, you may need to install the English (United States) language pack and its associated TTS voices through Windows Settings.
    - Go to `Settings > Time & language > Language & region`.
    - Under "Preferred languages", click "Add a language".
    - Search for and add the desired language (e.g., "English (United States)").
    - Once added, click the three dots next to the language and select "Language options".
    - Under "Speech", ensure "Text-to-speech" is installed.

### **🆕 Minimized Notification Issues**
- The notification should automatically disappear when reading stops
- If it persists, click it or use Win+F to clear it
- The notification cleanup is now improved and more reliable

## 📋 File Structure

```
TTS Application/
├── Main.ahk                 # Main application entry point
├── UIManager.ahk           # User interface management
├── HotkeyManager.ahk       # Keyboard shortcuts handling
├── VoiceManager.ahk        # Speech synthesis management
├── StateManager.ahk        # Application state management
└── SystrayManager.ahk      # System tray integration
```

## 🆕 Recent Improvements

### **Enhanced User Experience**
- ✅ **Three-tab Settings Panel**: General, Voices, and Shortcuts tabs
- ✅ **Built-in Shortcuts Reference**: Never forget a shortcut again
- ✅ **Smart Drag Zone**: Precise control over dragging behavior
- ✅ **Better Visual Feedback**: Clear separation between interactive areas
- ✅ **Start Minimized Option**: Choose to begin reading with panel minimized
- ✅ **Improved Notification Cleanup**: No more persistent notifications after reading ends

### **Technical Enhancements**
- ✅ **Optimized Event Handling**: More responsive drag and drop
- ✅ **Enhanced Position Management**: Better window positioning and memory
- ✅ **Improved Error Handling**: More robust GUI state management
- ✅ **Better Resource Cleanup**: Proper disposal of minimized notifications
- ✅ **State Management**: Added startMinimized option with persistence

### **Bug Fixes**
- ✅ **Fixed**: Minimized notification now properly disappears when reading stops
- ✅ **Fixed**: Better cleanup when stopping reading while minimized
- ✅ **Fixed**: Improved error handling for GUI destruction

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test with various text types and languages
4. Test the new drag zone and settings interaction
5. Test the start minimized option and notification cleanup
6. Submit a pull request

## 📄 License

[Add your license information here]

## 🙏 Acknowledgments

Built with AutoHotkey v2.0 and Windows SAPI for reliable cross-system compatibility.

---

**🎧 Happy Listening!** Transform any text into an engaging audio experience with intuitive controls, smart features, built-in help that's always at your fingertips, and now with the convenience of starting minimized for discreet operation.
