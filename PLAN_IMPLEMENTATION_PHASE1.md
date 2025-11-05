# Plan d'Implémentation - Phase 1
## Amélioration du Système de Détection de Langue

---

**Phase :** 1/3  
**Objectif :** Améliorer le système actuel de 85-90% à 90-92% de précision  
**Durée estimée :** 6 semaines  
**Priorité :** Critique  

---

## 📋 Tâches à Implémenter

### 1. Extension des Dictionnaires Français (Semaines 1-2)
**Objectif :** Équilibrer les dictionnaires FR (37 → 80+ mots)

#### 1.1 Mots Techniques Français
- **Informatique :** "développement", "programmation", "système", "application", "interface"
- **Sciences :** "recherche", "expérience", "théorie", "méthode", "analyse"
- **Affaires :** "entreprise", "management", "stratégie", "dévéloppement", "performance"

#### 1.2 Argot et Expressions Courantes
- **Familier :** "machin", "truc", "bidule", "chose", "bouquin"
- **Expressions :** "du coup", "genre", "comme ça", "bref", "en fait"
- **Oral :** "du genre", "voilà", "du coup", "quoi", "hein"

#### 1.3 Mots de Liaison Avancés
- **Concession :** "toutefois", "néanmoins", "cependant", "malgré", "quoique"
- **Cause :** "étant donné", "dans la mesure où", "puisque", "parce que"
- **Conséquence :** "en conséquence", "par conséquent", "ainsi", "d'où"

#### 1.4 Noms Propres Courants
- **Prénoms français :** "marie", "pierre", "jean", "sophie", "luc"
- **Lieux :** "paris", "lyon", "marseille", "toulouse", "bordeaux"

### 2. Implémentation des Seuils Adaptatifs (Semaines 3-4)
**Objectif :** Ajuster les seuils selon la longueur et complexité du texte

#### 2.1 Logique de Seuils Dynamiques
```autohotkey
; Texte court (1-10 caractères) : seuils élevés
shortTextThreshold := 3

; Texte moyen (11-50 caractères) : seuils standard  
mediumTextThreshold := 2

; Texte long (50+ caractères) : seuils réduits
longTextThreshold := 1
```

#### 2.2 Facteur de Confiance
- Calculer un score de confiance (0-1)
- Ajuster la détection selon la confiance
- Retourner "UNCERTAIN" si confiance < 0.7

### 3. Tests et Validation (Semaines 5-6)
**Objectif :** Valider l'amélioration de précision

#### 3.1 Jeu de Tests Automatisé
- **1000 cas de test FR/EN** couvrant différents types de texte
- **Tests de régression** pour s'assurer de la compatibilité
- **Benchmark de performance** (temps de détection)

#### 3.2 Métriques de Validation
- **Précision globale :** ≥ 90%
- **Précision textes courts :** ≥ 88%
- **Précision textes longs :** ≥ 92%
- **Temps moyen :** ≤ 5ms

---

## 🛠️ Fichiers à Modifier

### Fichiers Principaux
1. **`src/TextProcessor.ahk`**
   - Extension des dictionnaires français
   - Implémentation des seuils adaptatifs
   - Ajout du système de confiance

2. **`src/EnhancedLanguageDetector.ahk`** *(nouveau)*
   - Classe de détection hybride
   - Logique de fallback
   - Métriques et monitoring

### Fichiers de Support
3. **`tests/TestLanguageDetection.ahk`** *(nouveau)*
   - Suite de tests automatisés
   - Cas d'edge et régression

4. **`config/LanguageConfig.json`** *(nouveau)*
   - Configuration des seuils
   - Paramètres de confiance
   - Métriques de performance

---

## 📊 Métriques de Succès

| Métrique | Baseline | Objectif Phase 1 | Méthode |
|----------|----------|------------------|---------|
| **Précision globale** | 85-90% | ≥ 90% | Tests automatisés |
| **Précision FR** | 82-87% | ≥ 89% | Corpus français |
| **Temps détection** | 1-2ms | ≤ 5ms | Profiling |
| **Taux d'échec** | 10-15% | ≤ 8% | Monitoring |

---

## ⚡ Actions Immédiates

### 1. Extension Dictionnaire Français
- [ ] Ajouter 40+ mots français stratégiques
- [ ] Équilibrer avec le dictionnaire anglais (80+ mots)
- [ ] Tester l'impact sur la détection

### 2. Seuils Adaptatifs
- [ ] Implémenter la logique de longueur de texte
- [ ] Ajuster les seuils selon le contexte
- [ ] Valider avec des cas de test

### 3. Validation
- [ ] Créer la suite de tests
- [ ] Mesurer les performances
- [ ] Comparer avec le système actuel

---

## 🚀 Plan de Transition Phase 2

**Après validation Phase 1 :**
- Développement COM Server FastText
- Intégration de l'architecture hybride
- Tests de l'ensemble du système

---

*Prêt pour l'implémentation en mode Code*