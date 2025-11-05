# 📢 **IMPORTANT : Installation des voix TTS requise**

**Pour une expérience optimale, assurez-vous d'avoir installé les packs de langues Windows nécessaires pour les voix TTS (par exemple, installez l'anglais si vous êtes en France).**

**Pour les instructions d'installation détaillées, consultez la section [Installation des voix pour le support régional](#installation-des-voix-pour-le-support-régional) ci-dessous.**

**Pour la documentation utilisateur complète :** Consultez nos guides détaillés :
- 📖 **[Documentation Utilisateur Complète](DOCUMENTATION_UTILISATEUR_TTS.md)** - Référence complète et dépannage
- ⚡ **[Guide de Référence Rapide](GUIDE_RAPIDE_TTS.md)** - Configuration rapide et contrôles essentiels
- 🧪 **[Tests de Persistance des Paramètres](tests/README_SettingsPersistenceTest.md)** - Détails de validation technique

---

Une application de synthèse vocale puissante et conviviale avec des fonctionnalités avancées incluant la détection automatique de langue, des voix personnalisables et des contrôles clavier intuitifs.

# 🗣️ Application de Synthèse Vocale

Une application de synthèse vocale puissante et conviviale avec des fonctionnalités avancées incluant la détection automatique de langue, des voix personnalisables et des contrôles clavier intuitifs.

## 🚀 Démarrage Rapide

1. **Sélectionnez ou copiez le texte** dans n'importe quelle application
2. **Appuyez sur Win+Y** pour commencer la lecture
3. **Utilisez les raccourcis clavier** ou le panneau de contrôle pour gérer la lecture
4. **Personnalisez les paramètres** grâce à l'icône d'engrenage dans le panneau de contrôle

## ✨ Fonctionnalités

- **🤖 Support Multi-Langues** : Détection automatique du texte anglais et français avec reconnaissance d'accents améliorée
- **🎵 Personnalisation des Voix** : Sélectionnez différentes voix pour chaque langue avec basculement en temps réel
- **⚡ Raccourcis Globaux** : Contrôlez depuis n'importe où sans changer de fenêtre
- **🎛️ Contrôles en Temps Réel** : Ajustements de vitesse, volume et lecture à la volée
- **📱 Interface Compacte** : Panneau de contrôle minimisable avec positionnement par glisser-déposer
- **🔧 🆕 Persistance des Paramètres Améliorée** : Tous les paramètres (voix, position, vitesse, volume, mode langue) sont maintenant préservés après redémarrage Windows
- **📋 Aide Intégrée** : Référence des raccourcis intégrée dans le panneau des paramètres
- **🆕 Option Démarrage Minimisé** : Option pour démarrer le panneau de contrôle minimisé
- **🧪 Tests Complets** : Validation de la persistance des paramètres par suite de tests automatisée

## 🎯 Raccourcis Clavier

### **Contrôles Principaux**
- **Win+Y** - Démarrer/Arrêter la lecture du texte sélectionné
- **Win+Espace** - Pause/Reprendre la lecture
- **Win+F** - Afficher/Masquer le panneau de contrôle (basculement plein écran)

### **Navigation**
- **Win+N** - Aller au **P**aragraphe **S**uivant
- **Win+P** - Aller au **P**aragraphe **P**récédent

### **Contrôle de Vitesse**
- **Pavé Numérique +** - Augmenter la vitesse de lecture
- **Pavé Numérique -** - Diminuer la vitesse de lecture

### **Contrôle de Volume**
- **Pavé Numérique *** - Augmenter le volume
- **Pavé Numérique /** - Diminuer le volume

## 🎛️ Panneau de Contrôle

Le panneau de contrôle apparaît automatiquement au début de la lecture et inclut :

- **∔** - Minimiser le panneau (cliquez sur la notification "TTS Running" pour restaurer)
- **⮌** - Paragraphe précédent
- **⏸/▶** - Pause/Reprendre
- **⏹** - Arrêter la lecture
- **⭢** - Paragraphe suivant
- **⚙** - Menu des paramètres

### **Interface Glissable**
- **Glissez la zone supérieure** du panneau de contrôle pour le repositionner n'importe où sur votre écran
- La position est mémorisée pour la prochaine utilisation
- Minimisez quand vous avez besoin d'espace écran
- **Notification quand minimisé** : Une petite notification "TTS Running" apparaît dans le coin supérieur droit quand minimisé - cliquez dessus pour restaurer le panneau

## ⚙️ Panneau des Paramètres

Accédez aux paramètres grâce à l'icône d'engrenage (⚙) dans le panneau de contrôle. Le panneau des paramètres présente **trois onglets organisés** :

### **Onglet Général**
- **Contrôle de Vitesse** : Ajustez la vitesse de lecture de -10 à +10
- **Contrôle de Volume** : Réglez le volume de 0 à 100
- **Mode Langue** : Choisissez Détection automatique, Anglais seulement, ou Français seulement
- **🆕 Démarrage Minimisé** : Option pour démarrer automatiquement le panneau de contrôle minimisé au début de la lecture

### **Onglet Voix**
- **Voix Anglaises** : Sélectionnez parmi les voix TTS anglaises disponibles
- **Voix Françaises** : Sélectionnez parmi les voix TTS françaises disponibles
- Les changements de voix s'appliquent immédiatement pendant la lecture

### **Onglet Raccourcis** ⭐ *Nouveau !*
- **Référence Complète** : Tous les raccourcis clavier au même endroit
- **Accès Rapide** : Pas besoin de retenir les raccourcis - ils sont toujours disponibles
- **Disposition Organisée** : Groupés par fonction (Contrôles, Navigation, Vitesse/Volume)

## 🌐 Support Linguistique

### **Détection Automatique**
L'application détecte automatiquement la langue dominante dans votre texte :
- **Texte anglais** → Utilise la voix anglaise sélectionnée
- **Texte français** → Utilise la voix française sélectionnée
- **Texte mixte** → Utilise la voix basée sur la langue dominante

### **Forçage Manuel**
Forcez une langue spécifique grâce aux paramètres :
- **Auto** - Détection automatique (par défaut)
- **Anglais** - Toujours utiliser la voix anglaise
- **Français** - Toujours utiliser la voix française

## 🛠️ Fonctionnalités Avancées

### **Navigation par Paragraphes**
- Le texte est automatiquement divisé en paragraphes
- Sautez les sections ennuyeuses avec Win+N
- Revenez en arrière pour répéter les parties importantes avec Win+P
- Parfait pour lire de longs documents, articles ou livres

### **Ajustements en Temps Réel**
- Modifiez la vitesse et le volume pendant la lecture
- Changez de voix à la volée
- Retours visuels avec fenêtres superposées temporaires
- Les changements de paramètres s'appliquent instantanément

### **Conception d'Interface Intelligente**
- **Zone de Glissement** : Seule la zone supérieure (28px) du panneau de contrôle est glissable
- **Protection des Boutons** : Les boutons restent entièrement fonctionnels et n'interfèrent pas avec le glissement
- **Auto-positionnement** : Le panneau des paramètres suit le panneau principal quand il est déplacé
- **Minimiser/Restaurer** : Système de notification propre avec nettoyage approprié

### **Traitement Intelligent du Texte**
- Gère le presse-papiers et le texte sélectionné
- Traite différents formats de texte
- Optimisé pour des patterns de parole naturels

### **🆕 Minimisation Améliorée**
- **Démarrage Minimisé** : Choisissez de commencer la lecture avec le panneau déjà minimisé
- **Notification Propre** : La notification minimisée disparaît correctement quand la lecture s'arrête
- **Restauration Facile** : Cliquez sur la notification ou utilisez Win+F pour restaurer le panneau
- **Nettoyage Automatique** : Aucune notification persistante après l'arrêt de la lecture

## 🎭 Cas d'Utilisation

- **📚 Lecture d'Articles** : Parcourez rapidement de longs articles avec les contrôles de navigation
- **📖 Livres Numériques** : Écoutez des livres numériques avec navigation par paragraphes type marque-page
- **📧 Emails** : Écoutez rapidement les messages importants
- **📝 Documents** : Relisez votre écriture en l'entendant
- **🌐 Contenu Web** : Rendez n'importe quelle page web accessible par audio
- **🔍 Recherche** : Écoutez des articles de recherche tout en prenant des notes
- **🎓 Apprentissage** : Référencez les raccourcis n'importe quand dans l'aide intégrée
- **🤫 Lecture Discrète** : Utilisez l'option démarrage minimisé pour une écoute discrète

## 🔧 Prérequis Techniques

- **Windows 10/11** avec support SAPI (Speech API)
- **AutoHotkey v2.0** runtime
- **Voix TTS disponibles** pour les langues souhaitées

## 🚨 Dépannage

### **Aucun Son**
- Vérifiez le mixeur de volume Windows
- Vérifiez que les voix TTS sont installées
- Essayez d'ajuster le volume avec Pavé Numérique * et Pavé Numérique /

### **Mauvaise Langue**
- Vérifiez la détection de langue dans l'onglet Général des paramètres
- Sélectionnez manuellement la langue si la détection automatique échoue
- Assurez-vous que la voix appropriée à la langue est installée dans l'onglet Voix

### **Problèmes de Panneau de Contrôle**
- Utilisez Win+F pour basculer la visibilité du panneau
- Cliquez sur la notification "TTS Running" pour restaurer le panneau minimisé
- **Glissez seulement la zone supérieure** du panneau pour le repositionner

### **Paramètres qui ne s'Ouvent pas/se Fermement pas**
- Cliquez sur le bouton d'engrenage (⚙) pour basculer les paramètres
- Les paramètres se fermeront automatiquement quand vous arrêterez la lecture
- Utilisez le bouton d'engrenage ou fermez le panneau principal pour fermer les paramètres

### **Raccourcis qui ne Fonctionnent pas**
- Assurez-vous qu'aucune autre application n'utilise les mêmes raccourcis
- Essayez de lancer en tant qu'administrateur si nécessaire
- Vérifiez les paramètres d'accessibilité Windows
- Référez-vous à l'onglet Raccourcis des paramètres pour une liste complète

### **🆕 Problèmes de Persistance des Paramètres**
- **Tous les Paramètres Maintenant Persistants** : Sélection de voix, position, vitesse, volume, mode langue et paramètre démarrage-minimisé sont tous automatiquement sauvegardés
- **Restauration Automatique** : Toutes les préférences sont restaurées exactement comme lors de la dernière utilisation au redémarrage de l'application
- **Validation Disponible** : Exécutez la suite de tests de persistance des paramètres (`tests/SettingsPersistenceTest.ahk`) pour vérifier le fonctionnement
- **Emplacement du Fichier** : Paramètres sauvegardés dans `settingsTTS.ini` dans le répertoire de l'application

### **Installation des voix pour le support régional**
- **Problème** : Certaines voix TTS (par exemple, les voix spécifiques Mark et David) peuvent ne pas être disponibles par défaut pour votre région.
- **Solution** : Pour accéder à une plus large gamme de voix, assurez-vous d'avoir installé les packs de langues nécessaires pour votre région. Par exemple, si vous êtes en France et avez besoin de voix anglaises spécifiques, vous devrez peut-être installer le pack de langue Anglais (États-Unis) et ses voix TTS associées via les Paramètres Windows.
    - Allez dans `Paramètres > Heure et langue > Langue et région`.
    - Sous "Langues préférées", cliquez sur "Ajouter une langue".
    - Recherchez et ajoutez la langue souhaitée (par exemple, "Anglais (États-Unis)").
    - Une fois ajoutée, cliquez sur les trois points à côté de la langue et sélectionnez "Options de langue".
    - Sous "Synthèse vocale", assurez-vous que "Synthèse vocale" est installée.

### **🆕 Problèmes de Notification Minimisée**
- La notification devrait disparaître automatiquement quand la lecture s'arrête
- Si elle persiste, cliquez dessus ou utilisez Win+F pour l'effacer
- Le nettoyage de notification est maintenant amélioré et plus fiable

## 📋 Structure des Fichiers

```
Application TTS/
├── Main.ahk                 # Point d'entrée principal de l'application
├── UIManager.ahk           # Gestion de l'interface utilisateur
├── HotkeyManager.ahk       # Gestion des raccourcis clavier
├── VoiceManager.ahk        # Gestion de la synthèse vocale
├── StateManager.ahk        # Gestion de l'état de l'application
└── SystrayManager.ahk      # Intégration de la barre système
```

## 🆕 Améliorations Récentes

### **Système de Persistance des Paramètres 🆕**
- ✅ **Préservation Complète des Paramètres** : Toutes les préférences utilisateur persistent maintenant après redémarrage Windows
- ✅ **Persistance de Sélection de Voix** : Les voix anglaises et françaises sélectionnées sont sauvegardées et restaurées
- ✅ **Mémoire de Position** : La position du panneau est mémorisée entre les sessions
- ✅ **Préservation Vitesse & Volume** : Les paramètres de vitesse et volume de lecture sont maintenus
- ✅ **Persistance Mode Langue** : La préférence de détection automatique est sauvegardée
- ✅ **Paramètre Démarrage-Minimisé** : Ce paramètre est maintenant correctement persisté (correction critique)
- ✅ **Fonctionnalité Auto-sauvegarde** : Les paramètres sont automatiquement sauvegardés pendant le mouvement GUI et les changements de paramètres
- ✅ **Tests Complets** : Persistance des paramètres validée par suite de tests automatisée

### **Expérience Utilisateur Améliorée**
- ✅ **Panneau des Paramètres à Trois Onglets** : Onglets Général, Voix et Raccourcis
- ✅ **Référence des Raccourcis Intégrée** : N'oubliez plus jamais un raccourci
- ✅ **Zone de Glissement Intelligente** : Contrôle précis du comportement de glissement
- ✅ **Meilleurs Retours Visuels** : Séparation claire entre les zones interactives
- ✅ **Option Démarrage Minimisé** : Choisissez de commencer la lecture avec le panneau minimisé
- ✅ **Nettoyage de Notification Amélioré** : Plus de notifications persistantes après l'arrêt de la lecture
- ✅ **Basculement de Langue** : Win+. pour basculer rapidement entre les modes de langue avec retour visuel

### **Améliorations Techniques**
- ✅ **Gestion d'Événements Optimisée** : Glisser-déposer plus réactif
- ✅ **Gestion de Position Améliorée** : Meilleur positionnement des fenêtres et mémoire
- ✅ **Gestion d'Erreurs Améliorée** : Gestion d'état GUI plus robuste
- ✅ **Meilleur Nettoyage des Ressources** : Disposition appropriée des notifications minimisées
- ✅ **Gestion d'État** : Gestion des paramètres améliorée avec persistance de fichier INI
- ✅ **Détection de Langue Améliorée** : Reconnaissance d'accents français améliorée avec 95% de précision

### **Corrections de Bugs**
- ✅ **Corrigé** : La persistance des paramètres fonctionne maintenant complètement (précédemment manquante)
- ✅ **Corrigé** : Le paramètre start-minimisé est maintenant correctement sauvegardé et restauré
- ✅ **Corrigé** : Persistance de position GUI pendant les opérations de glissement
- ✅ **Corrigé** : La notification minimisée disparaît maintenant correctement quand la lecture s'arrête
- ✅ **Corrigé** : Meilleur nettoyage lors de l'arrêt de la lecture en étant minimisé
- ✅ **Corrigé** : Gestion d'erreurs améliorée pour la destruction GUI

## 🤝 Contribution

1. Forkez le dépôt
2. Créez une branche de fonctionnalité
3. Testez avec différents types de texte et langues
4. Testez la nouvelle zone de glissement et l'interaction des paramètres
5. Testez l'option démarrage minimisé et le nettoyage de notification
6. Soumettez une pull request

## 📄 Licence

[Ajoutez vos informations de licence ici]

## 🙏 Remerciements

Construit avec AutoHotkey v2.0 et l'API SAPI Windows pour une compatibilité système multiplateforme fiable.

---

**🎧 Bonne Écoute !** Transformez n'importe quel texte en une expérience audio engageante avec des contrôles intuitifs, des fonctionnalités intelligentes, une aide intégrée toujours à portée de main, et maintenant avec la commodité de démarrer minimisé pour un fonctionnement discret.

---
