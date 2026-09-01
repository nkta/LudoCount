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
- **Mise à Jour Intégrée** (Android) : L'application vérifie les GitHub Releases du dépôt et propose d'installer la dernière version sans passer par un store.

## 🛠 Technologies Utilisées

Ce projet est développé avec **Flutter** et utilise plusieurs packages clés :

- **State Management** : `provider`
- **Base de données locale** : `hive`
- **Internationalisation** : `flutter_localizations`, `intl`
- **QR Code** : `qr_flutter`, `mobile_scanner`
- **Partage par fichier** : `file_picker` (sélection), `share_plus` (partage système), `path_provider` (fichier temporaire)
- **Calcul** : `expressions` (pour l'évaluation des formules dynamiques)
- **Mise à jour in-app** : `http`, `package_info_plus`, `open_filex`

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

## 🔄 Mise à jour depuis l'application (Android)

LudoCount interroge les [GitHub Releases](https://github.com/nkta/LudoCount/releases) du dépôt, compare le tag de la dernière version publiée au champ `version:` de `pubspec.yaml`, et propose de télécharger l'APK de cette version puis de lancer l'installeur du système. La vérification a lieu une fois au lancement : une pastille apparaît alors sur l'icône de mise à jour de l'écran d'accueil, qui ouvre le détail de la version.

La fonctionnalité est masquée hors Android, seule plateforme où l'installation d'un APK est possible.

### Publier une version

1. Incrémenter `version:` dans `pubspec.yaml` (par exemple `1.1.0+2`).
2. Construire l'APK : `flutter build apk --release`.
3. Créer une release GitHub dont le **tag** porte le numéro de version (`v1.1.0` ou `1.1.0`) et y **attacher l'APK** en asset. Le corps de la release est affiché comme notes de version dans l'application.

L'APK doit être signé avec la même clé que la version déjà installée, faute de quoi Android refusera la mise à jour.

Publiez un **APK universel** (`flutter build apk --release`) : l'application retient le premier asset `.apk` de la release, sans distinguer les architectures. Une release construite avec `--split-per-abi` exposerait plusieurs APK dont un seul convient à l'appareil.

Les cas dégradés sont gérés : sans réseau l'application invite à vérifier la connexion, sans release publiée elle l'indique, et une release sans asset `.apk` renvoie vers sa page GitHub. Un téléchargement interrompu ou incomplet est effacé du cache et peut être relancé.

### Permissions Android

| Permission | Rôle |
| --- | --- |
| `INTERNET` | Interroger l'API GitHub et télécharger l'APK. Elle n'était déclarée que dans les manifestes `debug` et `profile` : elle manquait donc en `release`. |
| `REQUEST_INSTALL_PACKAGES` | Remettre l'APK téléchargé à l'installeur du système. |

`REQUEST_INSTALL_PACKAGES` ne suffit pas à elle seule : à la première tentative, Android ouvre l'écran « Installer des applications inconnues » pour que l'utilisateur autorise explicitement LudoCount.

L'APK est écrit dans le cache privé de l'application et exposé à l'installeur en `content://` par le `FileProvider` de `open_filex`. Les permissions média que ce paquet déclare (`READ_EXTERNAL_STORAGE`, `READ_MEDIA_*`) sont retirées via `tools:node="remove"` dans `android/app/src/main/AndroidManifest.xml`, l'application n'ouvrant que le fichier qu'elle a elle-même écrit.

> ⚠️ Google Play interdit qu'une application se mette à jour par un APK téléchargé hors du store. Si LudoCount y est publié un jour, cette fonctionnalité devra être désactivée dans la variante destinée au Play Store.

### Dépendances ajoutées

| Paquet | Justification |
| --- | --- |
| `http` | Appel à l'API GitHub et téléchargement streamé de l'APK avec progression ; testable via `MockClient` sans réseau. |
| `package_info_plus` | Lecture à l'exécution de la version compilée (`versionName` / `versionCode`), seul reflet fiable du champ `version:` de `pubspec.yaml`. |
| `path_provider` | Répertoire de cache où écrire l'APK. Déjà présente en dépendance transitive, simplement promue en dépendance directe. |
| `open_filex` | Ouverture de l'APK via un `FileProvider` : `url_launcher` ne peut pas ouvrir un `file://` depuis Android 7. |

## ☕ Soutenir le projet

Si vous aimez LudoCount, vous pouvez soutenir le développement en m'offrant un café via le lien intégré dans l'application ou directement ici : [Buy Me a Coffee](https://buymeacoffee.com/nkta1).

## 📄 Licence

Tous droits réservés. Ce code est disponible à des fins de consultation uniquement. Toute redistribution ou utilisation commerciale est interdite sans autorisation.
