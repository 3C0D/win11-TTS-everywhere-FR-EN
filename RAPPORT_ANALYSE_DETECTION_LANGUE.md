# Rapport d'Analyse : Système de Détection de Langue - win11-TTS-everywhere-FR-EN

## Vue d'ensemble du projet

Le projet **win11-TTS-everywhere-FR-EN** est une application AutoHotkey v2.0 qui offre des fonctionnalités de synthèse vocale (Text-to-Speech) avec détection automatique de langue français/anglais. L'application est structurée en plusieurs modules modulaires.

### Architecture du projet

- **TTS.ahk** : Fichier principal, point d'entrée de l'application
- **TextProcessor.ahk** : Contient les fonctions de détection de langue et traitement de texte
- **VoiceManager.ahk** : Gestion des voix et paramètres persistants
- **VoiceInitializer.ahk** : Initialisation et installation des voix Windows
- **UIManager.ahk** : Interface utilisateur et contrôles
- **HotkeyManager.ahk** : Gestion des raccourcis clavier
- **StateManager.ahk** : Gestion de l'état global de l'application

## Implémentation actuelle de la détection de langue

### 1. Fonction principale : DetermineDominantLanguage()

**Localisation** : [`src/TextProcessor.ahk:31-66`](src/TextProcessor.ahk:31)

**Fonctionnement** :
- Analyse le texte complet en paragraphes
- Calcule des scores pour chaque langue (français/anglais) via `CalculateLanguageScores()`
- Détermine la langue dominante basée sur les scores totaux
- Utilisée pour la sélection initiale de voix lors du démarrage de la lecture

**Code clé** :
```autohotkey
DetermineDominantLanguage(text) {
    paragraphs := SplitIntoParagraphs(text)
    totalFrenchScore := 0
    totalEnglishScore := 0
    totalWordCount := 0
    
    for paragraph in paragraphs {
        if (paragraph == "")
            continue
        
        frenchScore := 0
        englishScore := 0
        CalculateLanguageScores(paragraph, &frenchScore, &englishScore)
        
        totalFrenchScore += frenchScore
        totalEnglishScore += englishScore
        
        words := StrSplit(paragraph, " ")
        totalWordCount += words.Length
    }
    
    if (totalEnglishScore > totalFrenchScore) {
        return "EN"
    } else {
        return "FR" ; Default to French if scores are equal
    }
}
```

### 2. Calcul des scores linguistiques : CalculateLanguageScores()

**Localisation** : [`src/TextProcessor.ahk:69-126`](src/TextProcessor.ahk:69)

**Fonctionnement** :
- Utilise des listes de mots communs français (37 mots) et anglais (60+ mots)
- Applique des poids différents aux mots "distinctifs" (2x pour français, 2x pour anglais)
- Compte les caractères accentués français (+0.5 par caractère)
- Analyse les patterns linguistiques avec expressions régulières

**Dictionnaires de mots** :

**Mots français** : `["le", "la", "les", "un", "une", "des", "et", "ou", "mais", "donc", "or", "ni", "car", "que", "qui", "quoi", "dont", "où", "à", "au", "avec", "pour", "sur", "dans", "par", "ce", "cette", "ces", "je", "tu", "il", "elle", "nous", "vous", "ils", "elles", "mon", "ton", "son", "notre", "votre", "leur"]`

**Mots anglais** : `["the", "and", "or", "but", "so", "yet", "for", "nor", "that", "which", "who", "whom", "whose", "when", "where", "why", "how", "a", "an", "in", "on", "at", "with", "by", "this", "these", "those", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did", "will", "would", "shall", "should", "we", "to", "of", "them", "it", "you", "he", "she", "they", "my", "your", "his", "her", "our", "their", "me", "him", "us", "as", "if", "can", "could", "may", "might", "must", "about", "from", "into", "over", "under", "between", "through", "after", "before", "during", "while", "than", "then", "there", "here", "not", "no", "yes"]`

**PatternsRegex** :
- Français : `qu'[aeiouy]|c'est|n'[aeiouy]|l'[aeiouy]|d'[aeiouy]` (+3 points)
- Anglais : `ing\s|ed\s|'s\s|'ve\s|'re\s|'ll\s|'t\s|'d\s|th\s|wh\s` (+4 points)

### 3. Détection contextuelle : DetectLanguage()

**Localisation** : [`src/TextProcessor.ahk:128-167`](src/TextProcessor.ahk:128)

**Fonctionnement** :
- Version simplifiée utilisée pour la détection en temps réel
- Prend en compte un paramètre de contexte linguistique optionnel
- Applique une logique de seuils pour éviter les faux positifs
- Seuil de différence : 2 points pour l'anglais, 1 point pour le français

**Logique de seuils** :
```autohotkey
if (englishScore > frenchScore && (englishScore - frenchScore) >= 2) {
    return "EN"
} else if (frenchScore > englishScore && (frenchScore - englishScore) >= 1) {
    return "FR"
}
```

### 4. Gestion du mode AUTO : SetVoiceLanguage()

**Localisation** : [`src/VoiceInitializer.ahk:188-230`](src/VoiceInitializer.ahk:188)

**Fonctionnement** :
- Gère le mode de détection automatique (AUTO)
- Logique adaptative selon le contexte :
  - Texte complet → `DetermineDominantLanguage()`
  - Paragraphe individuel → `DetectLanguage()` avec contexte
  - Texte court (< 100 caractères) → `DetectLanguage()` sans contexte

## Gestion des voix françaises et anglaises

### Mapping des langues Windows

**Localisation** : [`src/VoiceManager.ahk:19-24`](src/VoiceManager.ahk:19)

```autohotkey
langMap := Map(
    "409", "EN",  ; English (US)
    "809", "EN",  ; English (UK)
    "40C", "FR",  ; French (FR)
    "C0C", "FR"   ; French (CA)
)
```

### Voix par défaut

**Localisation** : [`src/StateManager.ahk:22-25`](src/StateManager.ahk:22)

```autohotkey
selectedVoiceEN: "Microsoft Mark",  ; Selected English voice
selectedVoiceFR: "Microsoft Paul",   ; Selected French voice
```

### Installation automatique des voix

**Fonctionnalités** :
- Détection des voix OneCore manquantes dans le registre standard
- Installation automatique avec privilèges administrateur
- Création de mappings de compatibilité
- Redémarrage du service audio après installation

## Points faibles identifiés

### 1. Dictionnaires linguistiques limités

**Problème** :
- Listes de mots statiques et limitées
- Pas de mise à jour dynamique du vocabulaire
- Absence de termes techniques, noms propres, ou argot
- Déséquilibre dans la taille des dictionnaires (FR: 37 mots vs EN: 60+ mots)

**Impact** :
- Réduction de la précision pour les textes spécialisés
- Biais potentiel en faveur de l'anglais

### 2. Logique de seuils rigide

**Problème** :
- Seuils fixes (2 points pour EN, 1 point pour FR)
- Pas d'adaptation selon la longueur du texte
- Absence d'apprentissage à partir des corrections utilisateur

**Impact** :
- Faux positifs/négatifs pour les textes courts
- Manque de flexibilité selon le contexte

### 3. Absence d'analyse contextuelle avancée

**Problème** :
- Pas de prise en compte de la structure grammaticale
- Ignorance des dépendances entre paragraphes
- Absence d'analyse du sens ou de la sémantique

**Impact** :
- Difficultés avec les textes multilingues
- Problèmes avec les citations ou le code intégré

### 4. Support linguistique limité

**Problème** :
- Binaire FR/EN seulement
- Pas de support pour d'autres langues européennes
- Ignorance des variantes régionales (français canadien, anglais britannique)

**Impact** :
- Limitation de l'utilisabilité pour les utilisateurs multilingues
- Exclusion de marchés non anglophones/francophones

### 5. Performance et optimisations

**Problème** :
- Recalcul complet des scores à chaque paragraphe
- Pas de cache des résultats de détection
- Inefficace pour les longs textes

**Impact** :
- Ralentissement sur les textes longs
- Consommation CPU innecesaire

## Zones d'amélioration possibles

### 1. Amélioration des algorithmes de détection

**Suggestions** :
- Implémentation d'algorithmes de Machine Learning (Naive Bayes, SVM)
- Utilisation de modèles linguistiques pré-entraînés
- Analyse de n-grammes pour améliorer la précision
- Détection basée sur les caractéristiques morphologiques

### 2. Extension du support linguistique

**Suggestions** :
- Support pour l'espagnol, l'allemand, l'italien
- Reconnaissance des variantes régionales
- Détection automatique des nouvelles langues installées

### 3. Système d'apprentissage adaptatif

**Suggestions** :
- Mémorisation des corrections utilisateur
- Adaptation des seuils selon le contexte d'utilisation
- Statistiques de précision par type de texte

### 4. Optimisations techniques

**Suggestions** :
- Cache des résultats de détection
- Parallélisation du traitement des paragraphes
- Analyse incrémentale pour les longs textes

### 5. Interface utilisateur améliorée

**Suggestions** :
- Indication de confiance de la détection
- Possibilité de correction manuelle en temps réel
- Statistiques de précision par session

## Recommandations prioritaires

### Court terme (Facile à implémenter)

1. **Équilibrage des dictionnaires** : Augmenter le nombre de mots français pour équilibrer avec l'anglais
2. **Amélioration des seuils** : Seuils adaptatifs selon la longueur du texte
3. **Détection de confiance** : Affichage du niveau de certitude de la détection

### Moyen terme (Effort modéré)

1. **Algorithme Naive Bayes** : Remplacement du système de score par un classifieur probabiliste
2. **Support multilingue** : Extension à 4-5 langues européennes principales
3. **Cache intelligent** : Système de mise en cache des résultats de détection

### Long terme (Effort considérable)

1. **Machine Learning** : Intégration de modèles pré-entraînés
2. **Analyse sémantique** : Prise en compte du sens et du contexte
3. **Interface adaptative** : Apprentissage des préférences utilisateur

## Conclusion

Le système de détection de langue actuel, bien que fonctionnel, présente des limitations significatives qui impactent sa précision et sa flexibilité. L'approche basée sur les mots communs et les patterns regex est appropriée pour une première implémentation, mais nécessite des améliorations substantielles pour offrir une expérience utilisateur optimale.

Les recommandations proposées suivent une progression logique, permettant des améliorations incrémentales tout en préservant la compatibilité avec l'existant. La priorité devrait être donnée à l'équilibrage des dictionnaires et à l'amélioration des seuils, car ces modifications peuvent être implémentées rapidement avec un impact positif immédiat.

---

*Rapport généré le 2025-11-04 14:31:27*  
*Analyse basée sur la version 1.5.0 du projet*