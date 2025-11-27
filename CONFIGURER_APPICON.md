# Guide : Configurer l'icône de l'application (AppIcon)

## 🎯 Objectif
Faire apparaître votre logo sur l'écran d'accueil de l'iPhone en tant qu'icône de l'application.

## 📋 Étapes dans Xcode

### 1. Ouvrir Assets.xcassets
1. Dans Xcode, dans le navigateur de projet (panneau de gauche)
2. Trouvez et ouvrez le dossier `Assets.xcassets`
3. Vous devriez voir un élément nommé **"AppIcon"** (si pas présent, voir étape 2)

### 2. Si AppIcon n'existe pas
1. Cliquez sur le bouton **"+"** en bas de la liste des assets
2. Sélectionnez **"App Icons & Launch Images"** → **"App Icon"**
3. Un nouvel élément "AppIcon" apparaîtra

### 3. Ajouter votre logo dans AppIcon
1. Sélectionnez **"AppIcon"** dans la liste
2. Vous verrez plusieurs emplacements pour différentes tailles d'icônes
3. **Important :** Glissez votre image 1024x1024 dans l'emplacement **"App Store"** (1024pt)
4. Xcode peut vous proposer de générer automatiquement toutes les autres tailles à partir de cette image

### 4. Tailles requises (si génération automatique ne fonctionne pas)

Si vous devez remplir manuellement, voici les tailles nécessaires :

#### iPhone
- **Notification** (20pt) : 40x40, 60x60 px
- **Settings** (29pt) : 58x58, 87x87 px  
- **Spotlight** (40pt) : 80x80, 120x120 px
- **App** (60pt) : 120x120, 180x180 px

#### iPad
- **Notification** (20pt) : 40x40, 60x60 px
- **Settings** (29pt) : 58x58, 87x87 px
- **Spotlight** (40pt) : 80x80, 120x120 px
- **App** (76pt) : 76x76, 152x152 px
- **App** (83.5pt) : 167x167 px (iPad Pro)

#### App Store
- **1024x1024 px** (obligatoire)

### 5. Vérifier la configuration
1. Dans les Build Settings du projet, vérifiez que :
   - `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`
   - (C'est déjà configuré dans votre projet ✅)

### 6. Tester
1. **Nettoyer le build** : Product → Clean Build Folder (⇧⌘K)
2. **Reconstruire** : Product → Build (⌘B)
3. **Lancer sur le simulateur** : Product → Run (⌘R)
4. Vérifiez que l'icône apparaît sur l'écran d'accueil du simulateur

## ⚠️ Règles importantes pour l'icône App Store

- **Format** : PNG (sans transparence)
- **Taille exacte** : 1024x1024 pixels
- **Design** :
  - Image carrée (iOS appliquera les coins arrondis automatiquement)
  - Pas de texte (Apple peut rejeter)
  - Pas de version ou "beta"
  - Pas de transparence
  - Design simple et reconnaissable

## 🔄 Différence entre "logo" et "AppIcon"

- **"logo"** : Asset utilisé dans l'interface de l'application (déjà implémenté dans HomeView, ProfileView, LoginView)
- **"AppIcon"** : Asset utilisé pour l'icône sur l'écran d'accueil de l'iPhone

Les deux peuvent utiliser la même image, mais doivent être dans des assets séparés.

## ✅ Vérification finale

Après avoir configuré AppIcon :
1. L'icône doit apparaître sur l'écran d'accueil du simulateur
2. L'icône doit apparaître dans le dock du simulateur
3. L'icône sera utilisée automatiquement lors de la soumission à l'App Store

---

**Note** : Si vous avez déjà une image 1024x1024, glissez-la simplement dans l'emplacement "App Store" de AppIcon, et Xcode générera automatiquement toutes les autres tailles nécessaires.

