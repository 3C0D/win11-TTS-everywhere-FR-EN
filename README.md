# 🗣️ TTS Text-to-Speech Application

## ⚠️ VOICE INSTALLATION (REQUIRED)

**Without Windows voices, the application won't work!**

### Essential steps:
1. **Windows Settings** → "Time & language" → "Voices"
2. **Add voices**:
   - French (France)
   - English (United States)
3. **Click "Install"** for each voice
4. **Test** installed voices

For optimal experience, install Windows TTS voices (French + English). **Detailed help**: See [HELP_FR.md](HELP_FR.md) for complete French guide.

---

## 🚀 Quick Start

1. **Select or copy text** in any application
2. **Press Win+Y** to start reading
3. **Use shortcuts** or control panel to manage playback
4. **Customize** through gear icon (⚙) in control panel

## ✨ Features

- **🤖 Multi-Language Support**: Automatic FR/EN detection with accent recognition
- **🎵 Voice Customization**: Different voices for each language with real-time switching
- **⚡ Global Hotkeys**: Control from anywhere without window switching
- **🎛️ Real-time Controls**: Speed, volume, and playback adjustments on the fly
- **📱 Compact Interface**: Minimizable panel with drag positioning
- **🔧 Settings Persistence**: All preferences saved automatically
- **📋 Built-in Help**: Shortcuts reference in settings panel

## 🎮 ESSENTIAL CONTROLS

### **Main Controls**
| Shortcut | Action | Description |
|----------|--------|-------------|
| **Win+Y** | Start/Stop | Begin reading selected text |
| **Win+Space** | Pause/Resume | Interrupt or continue |
| **Win+F** | Show/Hide | Toggle control panel |

### **Navigation & Language**
| Shortcut | Action | Description |
|----------|--------|-------------|
| **Win+N** | Next paragraph | Jump to next section |
| **Win+P** | Previous paragraph | Go back |
| **Win+.** | Change language | Auto → English → French |

### **Quick Adjustments**
| Shortcut | Action | Description |
|----------|--------|-------------|
| **Numpad+** | Speed +0.5 | Increase reading speed |
| **Numpad-** | Speed -0.5 | Decrease reading speed |
| **Numpad*** | Volume +10 | Increase volume |
| **Numpad/** | Volume -10 | Decrease volume |

## 🎛️ USER INTERFACE

### Control panel:
```
┌─────────────────────────────────┐
│ ∔  ⏮  ⏸  ⏹  ⏭  ⚙             │
│ [Drag here to move]             │
└─────────────────────────────────┘
```

**Buttons:**
- **∔** : Minimize ("TTS Running" notification appears)
- **⏮/⏸/⏹/⏭** : Playback controls
- **⚙** : Settings (voices, speed, volume)

**Drag area:** Top zone (28px) to reposition panel

### Minimized notification:
- **Appears** in top-right when minimized
- **Click** to restore control panel
- **Disappears** automatically when stopped

## ⚙️ Settings

**Access**: Click gear icon (⚙) in control panel

### **General Tab**
- **Speed**: -10 to +10 (default: 2.5)
- **Volume**: 0 to 100 (default: 100)
- **Language Mode**: Auto/English/French
- **Start Minimized**: Panel starts hidden

### **Voices Tab**
- **English Voices**: Microsoft Mark, Zira, David (recommended)
- **French Voices**: Microsoft Paul, Hortense, Julie (recommended)
- **Real-time**: Changes apply immediately during reading

### **Shortcuts Tab**
- **Complete reference** of all keyboard shortcuts
- **Organized** by function (Controls, Navigation, Speed/Volume)

## 🌐 Language Support

### **Automatic Detection**
- **English text** → English voice
- **French text** → French voice  
- **Mixed text** → Based on dominant language
- **Accent Recognition**: Uses French accents (é, è, à, ç) for detection

### **Manual Override**
- **Auto** - Automatic detection (default)
- **English** - Always use English voice
- **French** - Always use French voice
- **Win+.** to cycle modes during reading

## 🛠️ Quick Troubleshooting

### **No Sound**
1. Check Windows volume mixer (Win+R → `sndvol`)
2. Test a voice (Windows Settings → Voices)
3. Test with Numpad */Numpad/ controls
4. Restart application

### **Wrong Language**
1. **Win+.** to change during reading
2. Check Language Mode in settings
3. Settings → Language mode → Force manually
4. Use French accents: é, è, à, ç
5. Ensure appropriate voices are installed

### **Control Panel Issues**
1. **Win+F** to toggle panel visibility
2. Click "TTS Running" notification to restore
3. Settings → General → Uncheck "Start minimized"
4. Restart application if needed

### **Shortcuts Not Working**
1. Close other TTS applications
2. Run as administrator if needed
3. Check Windows accessibility settings

## 🔧 Technical Requirements

- **Windows 10/11** with SAPI support
- **AutoHotkey v2.0** runtime
- **TTS voices** installed for desired languages

## 📁 Available Help Files

- **[HELP_EN.md](HELP_EN.md)** - Complete quick reference guide
- **[HELP_FR.md](HELP_FR.md)** - Guide complet en français

## 🎭 Use Cases

- **📚 Articles**: Speed through long reading
- **📖 E-books**: Listen with paragraph navigation  
- **📧 Emails**: Quick message listening
- **📝 Documents**: Proof-read by hearing
- **🌐 Web Content**: Make any webpage audible
- **🤫 Discreet**: Start minimized for quiet environments

---

## 📝 USAGE

1. **Select/copy** text
2. **Press Win+Y** → Reading starts
3. **Adjust** in real-time if needed
4. **Win+F** to hide panel

**More help:** Check French help file `HELP_FR.md`

---

**🎧 Happy Listening!** Transform any text into engaging audio with intuitive controls and smart features.

*TTS Application - Simplified version - 2025*
