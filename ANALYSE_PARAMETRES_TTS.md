# Analyse du Système de Gestion des Paramètres TTS

## Vue d'ensemble du système

L'application TTS utilise un système de gestion des paramètres basé sur un fichier INI (`settingsTTS.ini`) et un objet global `state` pour maintenir l'état de l'application.

## Architecture du système

### Fichiers principaux
- **`StateManager.ahk`** : Définit l'objet `state` global avec toutes les configurations
- **`VoiceManager.ahk`** : Contient les fonctions de sauvegarde/chargement des paramètres
- **`UIManager.ahk`** : Gère les interactions UI et sauvegardes automatiques
- **`TTS.ahk`** : Point d'entrée principal qui charge les paramètres au démarrage
- **`StartupManager.ahk`** : Gère le démarrage automatique
- **`SystrayManager.ahk`** : Gère les actions de fermeture

### Séquence d'initialisation (dans `TTS.ahk`)
```ahk
1. InitializeVoices()          ; ligne 26
2. voice := ComObject(...)     ; ligne 28
3. LoadVoiceSettings()         ; ligne 33  ⭐ CHARGEMENT DES PARAMÈTRES
4. InitializeSystray()         ; ligne 35
5. InitializeHotkeys()         ; ligne 38
```

## Analyse détaillée

### 1. Gestion du fichier settingsTTS.ini

**Localisation :** `A_ScriptDir . "\settingsTTS.ini"` (ligne 6 dans VoiceManager.ahk)

**Section utilisée :** `VoiceSettings`

**Paramètres sauvegardés :**
- `SelectedVoiceEN` : Voix anglaise sélectionnée
- `SelectedVoiceFR` : Voix française sélectionnée  
- `LanguageMode` : Mode de langue (AUTO/EN/FR)
- `Speed` : Vitesse de lecture
- `Volume` : Volume audio
- `StartMinimized` : Démarrage en mode minimisé

### 2. Fonctions de gestion des paramètres

#### LoadVoiceSettings() (lignes 121-148)
- ✅ Vérifie l'existence du fichier
- ✅ Utilise des valeurs par défaut si le fichier n'existe pas
- ✅ Charge tous les paramètres avec conversion de type appropriée
- ✅ Met à jour `internalRate` basé sur `speed`

#### SaveVoiceSettings() (lignes 96-118)
- ✅ Crée le répertoire si nécessaire
- ✅ Sauvegarde tous les paramètres principaux
- ✅ Messages de debug pour le suivi

### 3. Endroits de sauvegarde automatique

La sauvegarde est déclenchée automatiquement dans ces situations :

**Dans UIManager.ahk :**
- Changement de vitesse (ligne 606)
- Changement de volume (ligne 582)
- Changement de langue (ligne 744)
- Changement de voix anglaise (ligne 784)
- Changement de voix française (ligne 820)
- Activation/désactivation "Start Minimized" (ligne 560)

**Dans HotkeyManager.ahk :**
- Ajustement du volume via Numpad (lignes 61, 77)
- Changement de langue (ligne 213)

## 🚨 PROBLÈMES IDENTIFIÉS

### Problème Critique #1 : Position de la GUI non sauvegardée
**Impact :** Élevé

**Description :**
Les paramètres `guiX` et `guiY` sont stockés dans l'objet `state` mais ne sont **JAMAIS** sauvegardés dans le fichier INI.

**Code concernée :**
- `StateManager.ahk` lignes 20-21 : Définit les valeurs par défaut
- `UIManager.ahk` : Met à jour les positions (lignes 261-262, 314-315, 341-342)
- `VoiceManager.ahk` : `SaveVoiceSettings()` ne les sauvegarde pas

**Conséquence :**
La position de la fenêtre de contrôle n'est jamais préservée après redémarrage.

### Problème Critique #2 : Pas de sauvegarde lors de la fermeture
**Impact :** Élevé

**Description :**
Aucun mécanisme de sauvegarde automatique lors de la fermeture de l'application.

**Code concernée :**
- `SystrayManager.ahk` ligne 26 : `A_TrayMenu.Add("Exit", (*) => ExitApp())`
- Aucun gestionnaire `OnExit` ou `GuiClose` pour sauvegarder avant fermeture

**Conséquence :**
Si l'application se ferme sans trigger les sauvegardes manuelles, certains paramètres peuvent être perdus.

### Problème Mineur #3 : Messages de debug en français
**Impact :** Faible

**Description :**
Algunos mensajes de debug están en francés en lugar del inglés estándar.

**Code concernée :**
- `UIManager.ahk` ligne 56 : Commentaire en français
- `UIManager.ahk` ligne 210 : Comentario en francés

## 🔧 SOLUTIONS RECOMMANDÉES

### Solution 1 : Ajouter la sauvegarde de position (CRITIQUE)

**Modification dans VoiceManager.ahk :**
```ahk
; Ajouter ces lignes dans SaveVoiceSettings() après ligne 114
IniWrite(state.guiX, SETTINGS_FILE, SETTINGS_SECTION, "GuiX")
IniWrite(state.guiY, SETTINGS_FILE, SETTINGS_SECTION, "GuiY")
OutputDebug("Position saved: X=" . state.guiX . ", Y=" . state.guiY)
```

**Modification dans LoadVoiceSettings() :**
```ahk
; Ajouter après ligne 142
state.guiX := Number(IniRead(SETTINGS_FILE, SETTINGS_SECTION, "GuiX", state.guiX))
state.guiY := Number(IniRead(SETTINGS_FILE, SETTINGS_SECTION, "GuiY", state.guiY))
OutputDebug("Position loaded: X=" . state.guiX . ", Y=" . state.guiY)
```

### Solution 2 : Ajouter gestionnaire de fermeture (CRITIQUE)

**Ajout dans TTS.ahk :**
```ahk
; Ajouter après ligne 40
; Gestionnaire de fermeture pour sauvegarder les paramètres
OnExit(SaveSettingsOnExit)

; Fonction de sauvegarde à la fermeture
SaveSettingsOnExit(*) {
    OutputDebug("Application closing, saving settings...")
    SaveVoiceSettings()
    ExitApp()
}
```

### Solution 3 : Corriger les commentaires en français (MINEUR)

**Modifications dans UIManager.ahk :**
```ahk
; Ligne 56 : Changer de
; Utiliser la position sauvegardée dans l'objet state
; À :
; Use saved position from state object

; Ligne 210 : Changer de  
; Start dragging
; À :
; Start dragging only when in drag zone
```

## État du système de paramètres

### ✅ Fonctionnalités qui marchent correctement

1. **Chargement au démarrage** : `LoadVoiceSettings()` est appelé au bon moment
2. **Sauvegarde manuelle** : Tous les paramètres sont sauvegardés lors des changements UI
3. **Valeurs par défaut** : Le système gère l'absence du fichier INI
4. **Hotkeys** : Les paramètres sont sauvegardés lors des ajustements clavier
5. **Encodage** : Pas de problème d'encodage détecté
6. **Chemins** : Les chemins sont relatifs et corrects

### ❌ Problèmes identifiés

1. **Position de fenêtre non sauvegardée** (Critique)
2. **Pas de sauvegarde automatique à la fermeture** (Critique)
3. **Commentaires en français** (Mineur)

## Impact sur la préservation des paramètres

La raison principale pour laquelle les paramètres **semblent** ne pas être préservés après redémarrage Windows est probablement liée au **Problème #1** (position non sauvegardée) combiné au **Problème #2** (pas de sauvegarde à la fermeture).

Si l'application se ferme de manière inattendue (crash, arrêt forcé) ou si la position n'est jamais sauvegardée, l'utilisateur peut avoir l'impression que "rien n'est préservé", alors qu'en réalité seule la position de la fenêtre est perdue.

## Recommandations prioritaires

1. **URGENT** : Implémenter la Solution 1 (sauvegarde de position)
2. **URGENT** : Implémenter la Solution 2 (sauvegarde à la fermeture)  
3. **FAIBLE PRIORITÉ** : Corriger les commentaires français

Ces corrections devraient résoudre complètement le problème de préservation des paramètres après redémarrage Windows.