#Requires AutoHotkey v2.0
#Include "../src/TextProcessor.ahk"

; Test de détection prioritaire du français
; Test French priority detection with specific characters and words

class FrenchPriorityDetectionTest {
    
    RunAllTests() {
        this.TestFrenchAccentedCharacters()
        this.TestFrenchGuaranteedWords()
        this.TestFrenchApostrophePatterns()
        this.TestMixedContent()
        this.TestEdgeCases()
        
        MsgBox("Tests de détection prioritaire du français terminés!")
    }
    
    TestFrenchAccentedCharacters() {
        OutputDebug("=== Test des caractères accentués français ===")
        
        accentTests := [
            {text: "café", expected: "FR", description: "Mot avec é"},
            {text: "hôtel", expected: "FR", description: "Mot avec ô"},
            {text: "être", expected: "FR", description: "Mot avec ê"},
            {text: "où", expected: "FR", description: "Mot avec ù"},
            {text: "français", expected: "FR", description: "Mot avec ç"},
            {text: "naïf", expected: "FR", description: "Mot avec ï"},
            {text: "Noël", expected: "FR", description: "Mot avec ë"},
            {text: "à bientôt", expected: "FR", description: "Expression avec à et ô"},
            {text: "The café is open", expected: "FR", description: "Texte mixte avec accent français"},
            {text: "Programming with données", expected: "FR", description: "Texte technique avec accent"}
        ]
        
        for test in accentTests {
            result := DetectLanguage(test.text)
            status := (result == test.expected) ? "✓ PASS" : "✗ FAIL"
            OutputDebug(status . " - " . test.description . ": '" . test.text . "' -> " . result)
        }
    }
    
    TestFrenchGuaranteedWords() {
        OutputDebug("=== Test des mots français garantis ===")
        
        wordTests := [
            {text: "le système", expected: "FR", description: "Article 'le'"},
            {text: "la programmation", expected: "FR", description: "Article 'la'"},
            {text: "les données", expected: "FR", description: "Article 'les'"},
            {text: "du code", expected: "FR", description: "Contraction 'du'"},
            {text: "des fichiers", expected: "FR", description: "Article 'des'"},
            {text: "au bureau", expected: "FR", description: "Contraction 'au'"},
            {text: "très important", expected: "FR", description: "Adverbe 'très'"},
            {text: "beaucoup de travail", expected: "FR", description: "Expression 'beaucoup'"},
            {text: "toujours actif", expected: "FR", description: "Adverbe 'toujours'"},
            {text: "jamais utilisé", expected: "FR", description: "Adverbe 'jamais'"},
            {text: "voilà le résultat", expected: "FR", description: "Expression 'voilà'"},
            {text: "donc nous avons", expected: "FR", description: "Conjonction 'donc'"},
            {text: "alors que", expected: "FR", description: "Expression 'alors'"},
            {text: "ainsi que", expected: "FR", description: "Expression 'ainsi'"},
            {text: "aussi simple", expected: "FR", description: "Adverbe 'aussi'"},
            {text: "même chose", expected: "FR", description: "Adverbe 'même'"},
            {text: "encore une fois", expected: "FR", description: "Adverbe 'encore'"},
            {text: "déjà fait", expected: "FR", description: "Adverbe 'déjà'"},
            {text: "maintenant disponible", expected: "FR", description: "Adverbe 'maintenant'"},
            {text: "aujourd'hui seulement", expected: "FR", description: "Expression 'aujourd'hui'"}
        ]
        
        for test in wordTests {
            result := DetectLanguage(test.text)
            status := (result == test.expected) ? "✓ PASS" : "✗ FAIL"
            OutputDebug(status . " - " . test.description . ": '" . test.text . "' -> " . result)
        }
    }
    
    TestFrenchApostrophePatterns() {
        OutputDebug("=== Test des patterns d'apostrophes français ===")
        
        apostropheTests := [
            {text: "qu'il fait", expected: "FR", description: "Contraction qu'il"},
            {text: "qu'elle dit", expected: "FR", description: "Contraction qu'elle"},
            {text: "qu'on peut", expected: "FR", description: "Contraction qu'on"},
            {text: "l'eau est", expected: "FR", description: "Contraction l'eau"},
            {text: "l'ami de", expected: "FR", description: "Contraction l'ami"},
            {text: "l'école est", expected: "FR", description: "Contraction l'école"},
            {text: "d'abord nous", expected: "FR", description: "Contraction d'abord"},
            {text: "d'accord avec", expected: "FR", description: "Contraction d'accord"},
            {text: "n'est pas", expected: "FR", description: "Négation n'est"},
            {text: "n'ont pas", expected: "FR", description: "Négation n'ont"},
            {text: "c'est vrai", expected: "FR", description: "Expression c'est"},
            {text: "s'est passé", expected: "FR", description: "Expression s'est"},
            {text: "j'ai dit", expected: "FR", description: "Contraction j'ai"},
            {text: "j'étais là", expected: "FR", description: "Contraction j'étais"},
            {text: "m'a dit", expected: "FR", description: "Contraction m'a"},
            {text: "t'as vu", expected: "FR", description: "Contraction t'as"}
        ]
        
        for test in apostropheTests {
            result := DetectLanguage(test.text)
            status := (result == test.expected) ? "✓ PASS" : "✗ FAIL"
            OutputDebug(status . " - " . test.description . ": '" . test.text . "' -> " . result)
        }
    }
    
    TestMixedContent() {
        OutputDebug("=== Test du contenu mixte avec priorité française ===")
        
        mixedTests := [
            {text: "The système is working", expected: "FR", description: "Anglais + mot français avec accent"},
            {text: "Programming avec les données", expected: "FR", description: "Anglais + mots français"},
            {text: "function getName() { return 'très important'; }", expected: "FR", description: "Code avec string française"},
            {text: "SELECT * FROM table WHERE name = 'café'", expected: "FR", description: "SQL avec valeur française accentuée"},
            {text: "console.log('qu\\'il fait beau');", expected: "FR", description: "JavaScript avec contraction française"},
            {text: "Error: l'utilisateur n'est pas connecté", expected: "FR", description: "Message d'erreur français"},
            {text: "// TODO: améliorer la performance", expected: "FR", description: "Commentaire français avec accent"},
            {text: "git commit -m 'Ajout de la fonctionnalité'", expected: "FR", description: "Commande git avec message français"},
            {text: "HTTP 200 OK - Données récupérées avec succès", expected: "FR", description: "Message HTTP français avec accents"},
            {text: "npm install --save très-utile-package", expected: "FR", description: "Commande npm avec nom français"}
        ]
        
        for test in mixedTests {
            result := DetectLanguage(test.text)
            status := (result == test.expected) ? "✓ PASS" : "✗ FAIL"
            OutputDebug(status . " - " . test.description . ": '" . test.text . "' -> " . result)
        }
    }
    
    TestEdgeCases() {
        OutputDebug("=== Test des cas limites ===")
        
        edgeTests := [
            {text: "é", expected: "FR", description: "Un seul caractère accentué"},
            {text: "où", expected: "FR", description: "Mot français d'une syllabe"},
            {text: "le", expected: "FR", description: "Article français court"},
            {text: "qu'", expected: "FR", description: "Contraction partielle"},
            {text: "l'", expected: "FR", description: "Article contracté seul"},
            {text: "c'est", expected: "FR", description: "Expression française courte"},
            {text: "CAFÉ", expected: "FR", description: "Mot français en majuscules"},
            {text: "Très", expected: "FR", description: "Mot français avec majuscule"},
            {text: "QU'IL", expected: "FR", description: "Contraction en majuscules"},
            {text: "L'ÉCOLE", expected: "FR", description: "Mot contracté en majuscules"}
        ]
        
        for test in edgeTests {
            result := DetectLanguage(test.text)
            status := (result == test.expected) ? "✓ PASS" : "✗ FAIL"
            OutputDebug(status . " - " . test.description . ": '" . test.text . "' -> " . result)
        }
    }
}

; Exécuter les tests
test := FrenchPriorityDetectionTest()
test.RunAllTests()