# LudoCount

LudoCount est une application Flutter moderne conçue pour faciliter le comptage des points lors de vos soirées jeux de société. Que vous jouiez à des jeux classiques ou à des jeux avec des règles de score complexes, LudoCount s'adapte à vos besoins.

## 🚀 Fonctionnalités

### 🎮 Gestion de Parties
- **Nouvelle Partie** : Configuration rapide avec sélection des joueurs et du type de jeu.
- **Reprise de Partie** : Continuez votre dernière partie exactement là où vous l'avez laissée.
- **Historique** : Consultez l'historique complet de vos parties passées.

### ⚙️ Préréglages (Presets)
- **Presets Intégrés** : Support natif pour des jeux populaires comme 7 Wonders, Skull King, etc.
- **Presets Personnalisés** : Créez vos propres règles de score.
- **Mode Expert** :
  - Définissez des formules de score complexes.
  - Utilisez des conditions logiques pour le calcul des points.
  - Configurez des étiquettes de manches personnalisées.
- **Partage** : Exportez et importez vos presets via QR Code ou par fichier.

#### Format d’échange `.ludopreset`

Un preset exporté dans un fichier porte l’extension **`.ludopreset`**. Le fichier est un simple texte UTF-8 qui contient exactement le même code que le QR Code : le JSON du preset, compressé en gzip puis encodé en base64. Il peut donc être envoyé par mail ou messagerie, ce qui dépanne quand un preset est trop volumineux pour un QR Code, puis réimporté depuis l’écran *Presets* avec « Importer depuis un fichier ». Les espaces et retours à la ligne autour du code sont ignorés, et c’est le contenu — pas l’extension — qui décide de la validité à l’import.

### 👥 Gestion des Joueurs
- Créez et gérez une liste de joueurs pour un accès rapide lors du lancement d'une partie.

### 🎲 Outils
- **Lanceur de Dés** : Un outil intégré pour lancer des dés virtuels si vous en manquez.

## 🛠 Technologies Utilisées

Ce projet est développé avec **Flutter** et utilise plusieurs packages clés :

- **State Management** : `provider`
- **Base de données locale** : `hive`
- **Internationalisation** : `flutter_localizations`, `intl`
- **QR Code** : `qr_flutter`, `mobile_scanner`
- **Partage par fichier** : `file_picker` (sélection), `share_plus` (partage système), `path_provider` (fichier temporaire)
- **Calcul** : `expressions` (pour l'évaluation des formules dynamiques)

## 📱 Installation

1.  **Prérequis** : Assurez-vous d'avoir le [Flutter SDK](https://flutter.dev/docs/get-started/install) installé.
2.  **Cloner le dépôt** :
    ```bash
    git clone https://github.com/votre-utilisateur/ludocount.git
    cd ludocount
    ```
3.  **Installer les dépendances** :
    ```bash
    flutter pub get
    ```
4.  **Générer les fichiers de code** (pour Hive et autres générateurs) :
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
5.  **Lancer l'application** :
    ```bash
    flutter run
    ```

## ☕ Soutenir le projet

Si vous aimez LudoCount, vous pouvez soutenir le développement en m'offrant un café via le lien intégré dans l'application ou directement ici : [Buy Me a Coffee](https://buymeacoffee.com/nkta1).

## 📄 Licence

Tous droits réservés. Ce code est disponible à des fins de consultation uniquement. Toute redistribution ou utilisation commerciale est interdite sans autorisation.
