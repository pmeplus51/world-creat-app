# Guide pour partager le projet Xcode sur GitHub

## 📋 Étapes pour mettre le projet sur GitHub

### 1. Initialiser Git dans votre projet (si pas déjà fait)

Ouvrez le Terminal et naviguez vers votre projet :

```bash
cd "/Users/flemdechercher/Library/Autosave Information/World-Creat 2"
git init
```

### 2. Ajouter tous les fichiers au dépôt Git

```bash
git add .
git commit -m "Initial commit - Projet World-Creat 2"
```

### 3. Créer un dépôt sur GitHub

1. Allez sur [github.com](https://github.com)
2. Cliquez sur le bouton **"+"** en haut à droite → **"New repository"**
3. Nommez le dépôt (ex: `World-Creat-2`)
4. **Ne cochez PAS** "Initialize with README" (le projet existe déjà)
5. Cliquez sur **"Create repository"**

### 4. Connecter votre projet local à GitHub

GitHub vous donnera des commandes. Utilisez celles-ci (remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub) :

```bash
git remote add origin https://github.com/VOTRE_USERNAME/World-Creat-2.git
git branch -M main
git push -u origin main
```

Si vous utilisez SSH au lieu de HTTPS :

```bash
git remote add origin git@github.com:VOTRE_USERNAME/World-Creat-2.git
git branch -M main
git push -u origin main
```

### 5. Authentification GitHub

Si GitHub vous demande de vous authentifier :
- **HTTPS** : Utilisez un Personal Access Token (Settings → Developer settings → Personal access tokens)
- **SSH** : Configurez vos clés SSH (plus sécurisé pour le long terme)

---

## 👥 Pour votre associé : Cloner et travailler sur le projet

### 1. Cloner le dépôt

```bash
git clone https://github.com/VOTRE_USERNAME/World-Creat-2.git
cd World-Creat-2
```

### 2. Ouvrir dans Cursor

1. Ouvrez Cursor
2. File → Open Folder
3. Sélectionnez le dossier `World-Creat-2` que vous venez de cloner

### 3. Ouvrir dans Xcode

1. Double-cliquez sur `World-Creat 2.xcodeproj` dans Finder
2. Ou depuis le terminal : `open "World-Creat 2.xcodeproj"`

### 4. Travailler ensemble

**Pour récupérer les dernières modifications :**
```bash
git pull origin main
```

**Pour envoyer vos modifications :**
```bash
git add .
git commit -m "Description de vos modifications"
git push origin main
```

---

## ⚠️ Fichiers importants à vérifier

Le fichier `.gitignore` est déjà créé et ignore :
- `xcuserdata/` (paramètres utilisateur Xcode)
- `DerivedData/` (fichiers générés)
- `.DS_Store` (fichiers macOS)
- Secrets/API keys (si configurés)

**⚠️ IMPORTANT :** Si vous avez des clés API ou secrets dans `APIConfig.swift`, assurez-vous qu'ils ne sont pas commités ou utilisez des variables d'environnement.

---

## 🔄 Workflow recommandé pour travailler à deux

1. **Avant de commencer à travailler :**
   ```bash
   git pull origin main
   ```

2. **Faire vos modifications**

3. **Avant de pousser :**
   ```bash
   git pull origin main  # Récupérer les dernières modifications
   git add .
   git commit -m "Votre message de commit"
   git push origin main
   ```

4. **En cas de conflit :**
   - Git vous indiquera les fichiers en conflit
   - Ouvrez-les et résolvez les conflits manuellement
   - Puis : `git add .` → `git commit` → `git push`

---

## 📝 Commandes Git utiles

```bash
# Voir l'état du dépôt
git status

# Voir l'historique des commits
git log

# Voir les différences
git diff

# Créer une nouvelle branche (pour travailler sur une fonctionnalité)
git checkout -b nom-de-la-branche

# Revenir sur la branche principale
git checkout main
```

---

## 🆘 Problèmes courants

### "Permission denied" lors du push
→ Vérifiez votre authentification GitHub (token ou clé SSH)

### "Repository not found"
→ Vérifiez que vous avez les droits d'accès au dépôt GitHub

### Conflits de merge
→ Communiquez avec votre associé pour coordonner les modifications

---

**Bon travail en équipe ! 🚀**

