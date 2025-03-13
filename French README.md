# TTS Reader (Lecteur Text-to-Speech)

Une application simple pour lire du texte à haute voix en utilisant les voix de synthèse vocale disponibles sur Windows 11.

## Fonctionnalités

- Lecture de texte sélectionné ou copié dans le presse-papiers
- Détection automatique de la langue (français ou anglais)
- Contrôle de la vitesse et du volume de lecture
- Navigation par paragraphe
- Pause et reprise de la lecture
- Démarrage automatique avec Windows (optionnel)

## Installation

1. Téléchargez le fichier .exe depuis la page des releases
2. Double-cliquez sur l'application pour la lancer
3. Au premier démarrage, l'application vérifie les voix disponibles:
   - Si toutes les voix sont déjà correctement installées, l'application démarre normalement
   - Si des voix supplémentaires sont détectées mais non installées, l'application vous proposera de les installer
   - Si l'application redémarre, c'est normal - elle est en train d'installer les voix manquantes

4. Une icône apparaîtra dans la barre des tâches, indiquant que l'application est active

## Utilisation

1. Sélectionnez du texte dans n'importe quelle application **OU** utilisez du texte déjà copié dans le presse-papiers
   **IMPORTANT :** La sélection a toujours priorité sur le presse-papiers. Si vous souhaitez utiliser le texte du presse-papiers, assurez-vous qu'aucun texte n'est sélectionné à l'écran.
2. Appuyez sur **Win+Y** pour commencer la lecture
3. Utilisez les raccourcis ci-dessous pour contrôler la lecture

### Raccourcis clavier

- **Win+Y** : Démarrer/Arrêter la lecture
- **Win+Alt+Y** : Pause/Reprendre la lecture
- **Win+Ctrl+Y** : Passer au paragraphe suivant
- **Win+Shift+Y** : Revenir au paragraphe précédent
- **Pavé numérique +** : Augmenter la vitesse
- **Pavé numérique -** : Diminuer la vitesse
- **Pavé numérique *** : Augmenter le volume
- **Pavé numérique /** : Diminuer le volume

**Note :** Vous pouvez également consulter la liste complète des raccourcis en faisant un clic droit sur l'icône de TTS Reader dans la barre des tâches et en sélectionnant "Shortcuts...".

## Résolution des problèmes

Si l'application ne fonctionne pas correctement après l'installation des voix :

1. Double-cliquez à nouveau sur le fichier .exe
2. Lorsque le message vous demande si vous souhaitez remplacer l'instance existante, cliquez sur "Oui"
3. Testez à nouveau la fonctionnalité avec Win+Y

Cette opération redémarrera l'application et résoudra la plupart des problèmes courants.

## Démarrage automatique avec Windows

Pour configurer l'application afin qu'elle démarre automatiquement avec Windows :

1. Faites un clic droit sur l'icône de TTS Reader dans la barre des tâches
2. Cochez l'option "Run at startup" dans le menu contextuel

L'application créera automatiquement un raccourci dans le dossier de démarrage de Windows. Si un raccourci existe déjà, il sera mis à jour.

## Langues supportées

L'application détecte automatiquement si le texte est en français ou en anglais et utilise la voix appropriée.

## Configuration requise

- Windows 10 ou supérieur
- Voix Microsoft installées (l'application peut installer les voix manquantes)

## Licence

Ce logiciel est distribué sous licence MIT.