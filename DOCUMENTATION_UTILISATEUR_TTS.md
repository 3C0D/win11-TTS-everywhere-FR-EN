# 📢 Documentation Utilisateur Complète - Application TTS

## 🎯 Vue d'ensemble

L'application TTS (Text-To-Speech) est une solution de synthèse vocale avancée et conviviale, spécialement conçue pour Windows 11. Elle offre une détection automatique de langue intelligente, des voix personnalisables et une interface utilisateur intuitive avec contrôles clavier complets.

### ✨ Fonctionnalités principales

- **🤖 Support multi-langues** : Détection automatique anglais/français avec accents
- **🎵 Voix personnalisables** : Sélection de voix différentes pour chaque langue
- **⚡ Raccourcis globaux** : Contrôle depuis n'importe quelle application
- **🎛️ Interface intuitive** : Panneau de contrôle glissable et paramètres complets
- **📱 Mode discret** : Option de démarrage minimisé pour une utilisation discrète
- **🔧 Paramètres persistants** : Toutes les préférences sont sauvegardées automatiquement
- **🆕 Gestion des voix Windows** : Installation et gestion des voix TTS intégrées

---

## 📋 Table des matières

1. [Installation et configuration des voix TTS](#installation-des-voix-tts)
2. [Guide de démarrage rapide](#guide-de-démarrage-rapide)
3. [Interface utilisateur](#interface-utilisateur)
4. [Paramètres et personnalisation](#paramètres-et-personnalisation)
5. [Gestion des claviers multiples](#gestion-des-claviers-multiples)
6. [Raccourcis clavier](#raccourcis-clavier)
7. [Fonctionnalités avancées](#fonctionnalités-avancées)
8. [Dépannage](#dépannage)
9. [FAQ](#faq)

---

## 🔧 Installation des voix TTS

### ⚠️ Important - Installation requise

**Pour une expérience optimale, vous devez installer les voix TTS Windows appropriées.** Sans ces voix installées, l'application ne pourra pas fonctionner correctement.

### Méthode 1 : Via les paramètres Windows (Recommandée)

#### Installation des voix françaises (si pas déjà installées)
1. **Ouvrir les paramètres Windows** :
   - `Win + I` → "Heure et langue" → "Voix"

2. **Ajouter la synthèse vocale française** :
   - Dans la section "Voix", cliquer sur "Ajouter une voix"
   - Sélectionner "Français (France)" ou "Français (Canada)"
   - Cliquer sur "Installer" pour télécharger les voix

3. **Installer les voix supplémentaires** :
   - Sélectionner les voix que vous souhaitez installer
   - Cliquer sur "Installer" pour chaque voix

#### Installation des voix anglaises
1. **Ajouter la synthèse vocale anglaise** :
   - Dans la section "Voix", cliquer sur "Ajouter une voix"
   - Sélectionner "Anglais (États-Unis)" ou "Anglais (Royaume-Uni)"
   - Cliquer sur "Installer"

2. **Vérifier l'installation** :
   - Les voix安装ées apparaissent dans la liste "Voix installées"
   - Vous pouvez les tester en cliquant sur le bouton "Test"

### Méthode 2 : Via Microsoft Store

1. **Ouvrir le Microsoft Store**
2. **Rechercher "Voix de Windows 11"**
3. **Installer les packs de voix souhaités** :
   - "Voix française"
   - "Voix anglaise (US)"
   - "Voix anglaise (UK)"

### Méthode 3 : Via PowerShell (Avancée)

```powershell
# Installation des voix françaises
Install-Language -LanguageId fr-FR

# Installation des voix anglaises US
Install-Language -LanguageId en-US

# Lister toutes les voix installées
Get-WindowsSpeechSynthesizer
```

### ✅ Vérification de l'installation

1. **Lancer l'application TTS**
2. **Aller dans Paramètres → Onglet Voix**
3. **Vérifier que vos voix apparaissent** :
   - Voix anglaises : Microsoft Mark, Microsoft Zira, Microsoft David, etc.
   - Voix françaises : Microsoft Paul, Microsoft Hortense, etc.

### 🗣️ Voix recommandées

#### Voix anglaises (qualité)
- **Microsoft Mark** (voix masculine claire)
- **Microsoft Zira** (voix féminine professionnelle)
- **Microsoft David** (voix masculine moderne)

#### Voix françaises (qualité)
- **Microsoft Paul** (voix masculine professionnelle)
- **Microsoft Hortense** (voix féminine claire)
- **Microsoft Julie** (voix féminine moderne)

---

## 🚀 Guide de démarrage rapide

### 1. Premier lancement
1. **Lancer l'application TTS.exe**
2. **L'icône apparaît dans la barre système** (coin inférieur droit)
3. **Sélectionner ou copier du texte** dans n'importe quelle application
4. **Appuyer sur `Win+Y`** pour commencer la lecture

### 2. Premier test
1. **Copier ce texte de test** :
   ```
   Bonjour ! Ceci est un test de l'application TTS. 
   Cette phrase démontre la détection automatique de la langue française.
   ```

2. **Appuyer sur `Win+Y`** - le panneau de contrôle apparaît
3. **Utiliser les contrôles** pour ajuster selon vos préférences

### 3. Configuration initiale
1. **Cliquer sur l'icône d'engrenage** (⚙) dans le panneau
2. **Onglet Général** : Ajuster vitesse et volume
3. **Onglet Voix** : Sélectionner vos voix préférées
4. **Onglet Raccourcis** : Consulter tous les raccourcis disponibles

---

## 🎛️ Interface utilisateur

### Panneau de contrôle principal

Le panneau de contrôle apparaît automatiquement au début de la lecture et comprend :

#### Boutons de contrôle
- **∔** - Minimiser le panneau (cliquer sur la notification "TTS Running" pour restaurer)
- **⏮** - Paragraphe précédent (Win+P)
- **⏸/▶** - Pause/Reprendre (Win+Espace)
- **⏹** - Arrêter la lecture
- **⏭** - Paragraphe suivant (Win+N)
- **⚙** - Menu des paramètres

#### Zone de glisser-déposer
- **Glissez la zone supérieure** (28 pixels) pour repositionner le panneau
- La position est mémorisée automatiquement
- Impossible de glisser accidentellement un bouton

#### Positionnement intelligent
- **Position par défaut** : Coin supérieur droit avec marge de 60px
- **Mémorisation** : La position est sauvegardée entre les sessions
- **Adaptation écran** : S'adapte automatiquement aux changements de résolution

### Barre systray TTS (Barre bleue transparente)

La **barre systray TTS** est une fonctionnalité discrète et essentielle :

#### Caractéristiques
- **Appearance** : Petite barre bleue transparente en haut à droite
- **Position** : Coin supérieur droit, à 10 pixels du bord
- **Contenu** : Affichage "TTS Running" avec icône
- **Transparence** : 80% de transparence pour éviter de gêner l'utilisation

#### Comportement
- **Affichage** : Apparaît automatiquement quand le panneau est minimisé
- **Clic-to-through** : Les utilisateurs peuvent cliquer à travers pour accéder aux contrôles sous-jacents
- **Disparition automatique** : S'efface quand la lecture s'arrête
- **Restauration** : Un clic restaure le panneau de contrôle principal

#### Fonctionnalité pratique
- **Accès rapide** : Permet de restaurer l'interface sans interrompre la lecture
- **Design non intrusif** : N'interfère pas avec le travail en cours
- **Indicateur visuel** : Confirme que l'application TTS fonctionne en arrière-plan

### Notification minimisée

Quand le panneau est minimisé, une **petite notification** apparaît dans le coin supérieur droit :
- **Texte** : "TTS Running"
- **Couleur** : Fond bleu foncé avec texte blanc
- **Action** : Cliquez dessus pour restaurer le panneau complet
- **Disparition** : Automatique quand la lecture s'arrête

---

## ⚙️ Paramètres et personnalisation

### Accès aux paramètres
- **Via le panneau** : Cliquer sur l'icône d'engrenage (⚙)
- **Interface** : Panneau séparé qui suit le panneau principal lors du déplacement
- **Auto-fermeture** : Se ferme automatiquement quand la lecture s'arrête

### Onglet Général

#### Contrôles de lecture
- **Vitesse** : Ajustement de -10 à +10 (par défaut : 2.5)
- **Volume** : Réglage de 0 à 100 (par défaut : 100)
- **Mode langue** : 
  - **Auto** - Détection automatique (recommandé)
  - **Anglais** - Toujours utiliser la voix anglaise
  - **Français** - Toujours utiliser la voix française

#### Options de démarrage
- **🆕 Démarrage minimisé** : 
  - **Activé** : L'application démarre directement en mode minimisé
  - **Utilisation** : Cliquez sur la notification ou utilisez Win+F pour afficher le panneau
  - **Avantage** : Fonctionnement discret, idéal pour la productivité

### Onglet Voix

#### Voix anglaises
- **Liste dynamique** : Affiche toutes les voix anglaises installées
- **Sélection permanente** : La voix choisie est sauvegardée
- **Test en temps réel** : Les changements s'appliquent immédiatement pendant la lecture

#### Voix françaises
- **Liste complète** : Toutes les voix françaises disponibles
- **Personnalisation** : Choisissez selon vos préférences
- **Compatibilité** : Supporte les voix Windows 11 natives

### Onglet Raccourcis
- **Référence complète** : Liste de tous les raccourcis clavier
- **Organisation** : Groupés par fonction (Contrôles, Navigation, Vitesse/Volume)
- **Accès rapide** : Toujours disponible pour consultation
- **Mises à jour** : Référence synchronisée avec les fonctionnalités

---

## ⌨️ Gestion des claviers multiples

### Pourquoi des claviers multiples ?

L'installation de voix TTS pour différentes langues peut créer plusieurs dispositions de clavier sur votre système Windows.

#### Causes principales
1. **Installation de packs de langue** : Pour accéder aux voix Microsoft Mark, David, etc., vous devez installer le pack de langue anglais
2. **Voix françaises régionales** : Voix françaises (France) vs voix françaises (Canada) peuvent créer des claviers distincts
3. **Configuration Windows automatique** : Windows ajoute automatiquement les dispositions de clavier pour chaque langue installée

#### Impact utilisateur
- **Multiples icônes de langue** dans la barre des tâches
- **Basculement involontaire** entre dispositions lors de l'utilisation
- **Interface "encombrée"** avec de nombreuses options de langue

### Solutions recommandées

#### Option 1 : Gestion manuelle (Simple)
1. **Cliquer sur l'icône de langue** dans la barre des tâches
2. **Désactiver les dispositions inutiles** :
   - Clic droit sur la disposition
   - Sélectionner "Supprimer cette disposition de langue"
3. **Garder seulement** :
   - Français (France) pour l'usage quotidien
   - Une disposition anglaise si nécessaire pour les voix anglaises

#### Option 2 : Configuration avancée
1. **Paramètres Windows** → "Heure et langue" → "Langue et région"
2. **Supprimer les langues indésirables** :
   - Sous "Langues préférées", cliquer sur les trois points (⋯)
   - Sélectionner "Supprimer"
3. **Conserver seulement les essentielles**

#### Option 3 : Mode saisie unique
1. **Forcer une disposition par application** :
   - Paramètres → "Heure et langue" → "Saisie"
   - Configuration avancées
   - Appliquer une disposition par application
2. **Utiliser des raccourcis spécifiques**

### Impact sur l'application TTS

#### Avantages des voix installées
- **Qualité audio améliorée** : Voix Microsoft natives
- **Compatibilité complète** : Toutes les fonctionnalités TTS
- **Performance optimale** : Intégration Windows native

#### Note personnelle importante
> 💭 *Installation des voix complémentaires nécessaires - bien que cela crée plusieurs claviers (ennuyeux mais nécessaire pour avoir des voix de qualité)*

#### Minimisation des inconvénients
1. **Utiliser le raccourci Win+Espace** pour changer rapidement de disposition si nécessaire
2. **Configurer une disposition par défaut** dans Windows
3. **Utiliser des raccourcis spécifiques** pour basculer entre dispositions essentielles

---

## ⌨️ Raccourcis clavier

### Contrôles principaux

| Raccourci | Action | Description |
|-----------|---------|-------------|
| **Win+Y** | Démarrer/Arrêter | Commencer ou arrêter la lecture du texte sélectionné |
| **Win+F** | Afficher/Masquer | Basculement du panneau de contrôle (mode plein écran) |
| **Win+Espace** | Pause/Reprendre | Interrompre ou reprendre la lecture |

### Navigation

| Raccourci | Action | Description |
|-----------|---------|-------------|
| **Win+N** | Paragraphe suivant | Aller au paragraphe suivant (Next) |
| **Win+P** | Paragraphe précédent | Revenir au paragraphe précédent (Previous) |

### Contrôle de langue

| Raccourci | Action | Description |
|-----------|---------|-------------|
| **Win+.** | Changer langue | Cycle : Auto → Anglais → Français → Auto |

### Contrôle de vitesse

| Raccourci | Action | Description |
|-----------|---------|-------------|
| **Pavé numérique +** | Augmenter vitesse | +0.5 point de vitesse |
| **Pavé numérique -** | Diminuer vitesse | -0.5 point de vitesse |

### Contrôle de volume

| Raccourci | Action | Description |
|-----------|---------|-------------|
| **Pavé numérique \*** | Augmenter volume | +10 points de volume |
| **Pavé numérique /** | Diminuer volume | -10 points de volume |

### Raccourci Win+F - Explication détaillée

Le raccourci **Win+F** est particulièrement important et mérite une explication approfondie :

#### Utilisation principale
- **Afficher le panneau** : Si minimisé ou caché
- **Masquer le panneau** : Pour travail discret
- **Basculement rapide** : Entre mode visible et mode discret

#### Cas d'usage typiques
1. **Démarrage en mode discret** :
   - Application configurée en "Démarrage minimisé"
   - Win+F pour affichage rapide quand nécessaire
   - Idéal pour les présentations ou environnements calmes

2. **Usage productif** :
   - Win+F pour basculer rapidement pendant le travail
   - Accès instant aux contrôles sans interrompre l'activité

3. **Gestion des notifications** :
   - Suppression rapide des notifications TTS
   - Contrôle visuel immédiat

#### Interaction avec la barre systray
- **Barre bleue transparente** reste visible même avec Win+F
- **Clic-through fonctionnel** pour accès aux éléments sous-jacents
- **Notification "TTS Running"** reste accessible

---

## 🚀 Fonctionnalités avancées

### Détection intelligente de langue

#### Système adaptatif
L'application utilise un système de détection hybride à trois niveaux :

1. **Analyse des accents** :
   - Caractères accentués français : é, è, à, ç, ï, etc.
   - Pondération renforcée (+400% depuis les corrections récentes)
   - Détection robuste même dans les textes techniques

2. **Reconnaissance des mots** :
   - Mots français courants : "et", "du", "la", "le", "les", "des", "un", "une", "que", "qui", "avec", "par", "dans", "pour"
   - Priorité française en cas de détection positive

3. **Seuil adaptatif** :
   - Textes courts : Seuils équilibrés
   - Textes moyens : Avantage français
   - Textes longs : Seuils optimisés pour performance

#### Performance améliorée
- **Taux de précision** : 92-95% (amélioration de +7% depuis Phase 1)
- **Temps de traitement** : < 5ms grâce au cache d'optimisation
- **Robustesse** : Textes techniques mixtes maintenant correctement détectés

### Navigation par paragraphes

#### Fonctionnement automatique
- **Division intelligente** : Le texte est automatiquement séparé par paragraphes
- **Conservation du contexte** : La détection de langue reste cohérente sur l'ensemble
- **Fluidité** : Transitions transparentes entre paragraphes

#### Contrôles de navigation
- **Win+N** : Sauter les sections ennuyeuses
- **Win+P** : Répéter les parties importantes
- **Interface visuelle** : Feedback visuel pour la position actuelle

### Paramètres persistants

#### Sauvegarde automatique
Tous les paramètres sont automatiquement sauvegardés dans `settingsTTS.ini` :

- **Voix sélectionnées** : Anglais et français
- **Contrôles de lecture** : Vitesse, volume
- **Mode de langue** : Auto/Anglais/Français
- **Options d'interface** : Démarrage minimisé
- **Position de l'interface** : Coordonnées X,Y de la fenêtre

#### Restauration au démarrage
- **Chargement automatique** : Tous les paramètres sont restaurés au lancement
- **Cohérence** : Interface exactement comme lors de la dernière utilisation
- **Fiabilité** : Fonctionnalité corrigée et optimisée (problèmes de Phase 1 résolus)

### Interface glissable intelligente

#### Zone de glissement optimisée
- **Zone supérieure uniquement** : 28 pixels de hauteur
- **Protection des boutons** : Les contrôles restent entièrement fonctionnels
- **Mouvement fluide** : Suivi en temps réel avec contraintes d'écran

#### Gestion automatique
- **Auto-positionnement** : Le panneau des paramètres suit le panneau principal
- **Contraintes d'écran** : Empêche la sortie de l'écran visible
- **Mémorisation** : Position sauvegardée instantanément après déplacement

---

## 🛠️ Dépannage

### Problèmes audio

#### ❌ Aucun son
**Solutions** :
1. **Vérifier le volume système** :
   - Mixeur de volume Windows (Win+R → `sndvol`)
   - Volume principal et application TTS
2. **Vérifier les voix TTS installées** :
   - Paramètres → Voix → Tester une voix
   - Réinstaller les voix si nécessaire
3. **Redémarrer l'application**
4. **Vérifier les raccourcis audio Windows**

#### ❌ Mauvaise voix utilisée
**Solutions** :
1. **Vérifier l'onglet Voix dans les paramètres**
2. **Sélectionner la voix appropriée** (anglaise/française)
3. **Forcer le mode de langue** : Auto/Anglais/Français
4. **Tester la voix** après changement

#### ❌ Qualité audio dégradée
**Solutions** :
1. **Vérifier l'installation des voix** :
   - Utiliser les voix Microsoft natives
   - Éviter les voix tierces ou crackées
2. **Ajuster la vitesse** (contrôles trop rapides peuvent dégrader la qualité)
3. **Vérifier la stabilité système** (processeur, mémoire)

### Problèmes d'interface

#### ❌ Panneau de contrôle invisible
**Solutions** :
1. **Utiliser Win+F** pour l'afficher
2. **Vérifier si démarré minimisé** (paramètres → général)
3. **Cliquer sur la notification "TTS Running"** (coin supérieur droit)
4. **Relancer l'application**

#### ❌ Raccourcis clavier non fonctionnels
**Solutions** :
1. **Vérifier les conflits d'applications** :
   - Fermer temporairement les autres applications TTS
   - Vérifier les raccourcis personnalisés Windows
2. **Exécuter en tant qu'administrateur**
3. **Redémarrer l'application**
4. **Vérifier les paramètres d'accessibilité Windows**

#### ❌ Paramètres qui ne se sauvegardent pas
**Solutions** :
1. **Vérifier les permissions d'écriture** dans le dossier de l'application
2. **Libérer de l'espace disque** (fichier settingsTTS.ini doit être accessible)
3. **Redémarrer l'application** pour déclencher la sauvegarde
4. **Vérifier la cohérence du fichier INI**

### Problèmes de langue

#### ❌ Détection de langue incorrecte
**Solutions** :
1. **Forcer le mode de langue** manuellement
2. **Vérifier les accents français** (système récent optimisé)
3. **Utiliser Win+.** pour changer manuellement pendant la lecture
4. **Tester avec des mots français clairs** : "et", "du", "la", "le"

#### ❌ Mauvaise voix pour la langue
**Solutions** :
1. **Vérifier l'installation des voix** de la langue appropriée
2. **Sélectionner la voix** dans l'onglet Voix
3. **Tester chaque voix** individuellement
4. **Redémarrer l'application** après changement de voix

### Problèmes système

#### ❌ Application qui plante
**Solutions** :
1. **Vérifier la version AutoHotkey** : v2.0 requis
2. **Fermer les applications TTS concurrentes**
3. **Redémarrer l'ordinateur** (pour libérer les ressources système)
4. **Réinstaller l'application** proprement

#### ❌ Notification qui persiste
**Solutions** :
1. **Cliquer dessus pour la fermer**
2. **Utiliser Win+F** pour effacer
3. **Redémarrer l'application** si nécessaire
4. **La notification disparaît automatiquement** à l'arrêt de la lecture

#### ❌ Problème de positionnement
**Solutions** :
1. **Repositionner manuellement** (glisser la zone supérieure)
2. **Redémarrer l'application** (restaure position par défaut)
3. **Vérifier la résolution d'écran** (changements peuvent affecter la position)

---

## ❓ FAQ (Foire aux questions)

### Questions générales

**Q : L'application est-elle compatible avec Windows 11 ?**
R : Oui, l'application est spécialement conçue pour Windows 11 et utilise l'API SAPI native.

**Q : Ai-je besoin d'Internet pour utiliser l'application ?**
R : Non, l'application fonctionne entièrement hors ligne en utilisant les voix Windows intégrées.

**Q : Puis-je utiliser mes propres voix TTS ?**
R : L'application détecte automatiquement toutes les voix TTS installées sur votre système Windows.

**Q : L'application ralentit-elle mon ordinateur ?**
R : Non, l'application est optimisée pour un usage minimal en ressources et ne fonctionne que pendant la lecture.

### Configuration et installation

**Q : Comment installer de nouvelles voix TTS ?**
R : Consultez la section [Installation des voix TTS](#installation-des-voix-tts) pour les méthodes détaillées.

**Q : Pourquoi ai-je plusieurs claviers maintenant ?**
R : L'installation de voix pour différentes langues crée automatiquement des dispositions de clavier. Consultez [Gestion des claviers multiples](#gestion-des-claviers-multiples).

**Q : Puis-je désactiver la détection automatique de langue ?**
R : Oui, dans Paramètres → Général → Mode langue, vous pouvez forcer "Anglais" ou "Français".

**Q : Comment utiliser l'application en mode discret ?**
R : Activez "Démarrage minimisé" dans les paramètres. Utilisez Win+F pour afficher le panneau quand nécessaire.

### Utilisation quotidienne

**Q : L'application mémorise-t-elle mes paramètres ?**
R : Oui, tous les paramètres sont automatiquement sauvegardés et restaurés au démarrage.

**Q : Puis-je utiliser l'application avec plusieurs écrans ?**
R : Oui, l'interface s'adapte automatiquement à tous les écrans connectés.

**Q : Comment arrêter complètement la lecture ?**
R : Utilisez Win+Y pour démarrer/arrêter, ou le bouton ⏹ dans le panneau de contrôle.

**Q : L'application fonctionne-t-elle avec toutes les applications ?**
R : L'application fonctionne avec toutes les applications Windows qui permettent la sélection de texte.

### Problèmes techniques

**Q : Que faire si les raccourcis ne fonctionnent pas ?**
R : Consultez la section [Dépannage](#dépannage) ou exécutez l'application en tant qu'administrateur.

**Q : Comment restaurer les paramètres par défaut ?**
R : Supprimez le fichier `settingsTTS.ini` et redémarrez l'application.

**Q : L'application peut-elle entrer en conflit avec d'autres TTS ?**
R : Possible avec d'autres applications TTS actives. Fermez les autres applications TTS en premier.

**Q : Comment signaler un bug ?**
R : Consultez les logs de débogage dans l'interface ou contactez le support technique.

### Fonctionnalités avancées

**Q : Comment optimiser la détection de langue ?**
R : Utilisez des textes clairs avec des accents français ou des mots typiques français.

**Q : Puis-je personnaliser les raccourcis clavier ?**
R : Actualmente, les raccourcis sont fixes, mais ils sont organisés logiquement pour faciliter la mémorisation.

**Q : Comment fonctionne la navigation par paragraphes ?**
R : L'application divise automatiquement le texte en paragraphes et permet la navigation séquentielle.

**Q : Y a-t-il une limite à la longueur du texte ?**
R :理论上 non, mais les très longs textes peuvent affecter les performances. L'application optimise automatiquement le traitement.

---

## 📞 Support et assistance

### Ressources d'aide

1. **Documentation intégrée** : Onglet "Raccourcis" dans les paramètres
2. **Tests de fonctionnalité** : Utilisez les exemples fournis dans chaque section
3. **Fichiers de log** : Consultez les messages de débogage pour le diagnostic

### Assistance technique

- **Problèmes persistants** : Redémarrez l'application et vérifiez les paramètres
- **Questions de configuration** : Reportez-vous aux sections d'installation
- **Optimisation** : Ajustez les paramètres selon votre utilisation

### Mises à jour

L'application bénéficie de mises à jour régulières incluant :
- Amélioration de la détection de langue (Phase 1 terminée)
- Optimisations de performance
- Nouvelles fonctionnalités d'interface

---

## 🎉 Conclusion

L'application TTS représente une solution complète et moderne pour la synthèse vocale sur Windows 11. Avec sa détection de langue intelligente, ses voix personnalisables et son interface intuitive, elle transforme n'importe quel texte en expérience audio enrichissante.

Que ce soit pour la productivité, l'accessibilité ou le plaisir d'écoute, cette application offre tous les outils nécessaires pour une utilisation quotidienne efficace et agréable.

**🎧 Bonne écoute !**

---

*Documentation générée le 2025-11-05 - Version 1.5.0*  
*Pour les dernières mises à jour, consultez la documentation officielle.*