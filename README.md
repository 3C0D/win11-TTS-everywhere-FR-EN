# 🗣️ TTS Reader - Text-to-Speech

**📁 French help available:** [HELP_FR.md](HELP_FR.md) (Aide en français)

---

## ⚠️ IMPORTANT: Install voices first!

**For the application to work properly, install Windows TTS voices:**

**Windows Settings** → "Time & language" → "Speech" → Add **French (France)** and **English (United States)** → Install each voice → Test them

The application automatically detects all SAPI voices available on your system.

---

## 🚀 How it works

Double-click **tts.exe** to launch the application. An icon appears in the system tray.

**Right-click the tray icon** → Menu with quick shortcuts and "Run at startup" to launch with Windows

**Basic usage:**
- **Select text** anywhere (or copy it without selection)
- **Win+Y** → Starts reading (and stops it too)
- Use **shortcuts** or the **interface** to control playback

![TTS Reader Interface](assets/UI.png)

**Handy tip:** Selection always takes priority over clipboard. For example, with an LLM, you can copy the entire response then select just a part to read only that section.

---

## 🎯 Essential shortcuts

**Win+Y** → Start/Stop reading   
**Win+F** → Show/Hide interface  
**Win+Space** → Pause/Resume  
**Win+N** / **Win+P** → Next/Previous paragraph
  
**Numpad:**  
**+** / **-** → Speed  
**\*** / **/** → Volume  
**Win+.** → Change language (Auto → English → French)

*(All shortcuts are in the "Shortcuts" tab of the interface)*

---

## ⚙️ Settings (⚙ button in the interface)

**General Tab:**
- **Language**: Auto mode (automatically detects French/English), fixed English or French
- **Start minimized**: Starts without showing the interface (remember Win+F to show it again!)

**Voices Tab:**
Choose which voice to use for English and French. In Auto mode, the application automatically switches based on the language detected in each paragraph.

**Shortcuts Tab:**
Complete list of available keyboard shortcuts.

---

## 🎤 Microphone Management

The application **automatically mutes the microphone** during text-to-speech reading to prevent audio feedback.

- **During reading**: Microphone is muted
- **During pause**: Microphone is unmuted  
- **After stop**: Microphone is unmuted

If your microphone has a different name than "Microphone" in Windows, you may need to adjust the device name in the source code.

---

**That's it! The interface is intuitive, you'll discover the rest by using it.**