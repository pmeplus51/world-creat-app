#!/bin/bash

# Script pour initialiser Git et pousser vers GitHub
# Usage: ./setup-github.sh

echo "🚀 Configuration Git pour World-Creat 2"
echo ""

# Vérifier si Git est installé
if ! command -v git &> /dev/null; then
    echo "❌ Git n'est pas installé. Installez-le depuis https://git-scm.com"
    exit 1
fi

# Vérifier si on est déjà dans un dépôt Git
if [ -d ".git" ]; then
    echo "ℹ️  Le projet est déjà un dépôt Git"
    read -p "Voulez-vous continuer quand même ? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "📦 Initialisation du dépôt Git..."
    git init
fi

echo ""
echo "📝 Ajout des fichiers..."
git add .

echo ""
read -p "💬 Message de commit (ou appuyez sur Entrée pour 'Initial commit'): " commit_message
if [ -z "$commit_message" ]; then
    commit_message="Initial commit - Projet World-Creat 2"
fi

git commit -m "$commit_message"

echo ""
echo "✅ Commit créé avec succès !"
echo ""
echo "📤 Pour pousser vers GitHub :"
echo ""
echo "1. Créez un nouveau dépôt sur GitHub (https://github.com/new)"
echo "2. Puis exécutez ces commandes (remplacez VOTRE_USERNAME) :"
echo ""
echo "   git remote add origin https://github.com/VOTRE_USERNAME/World-Creat-2.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Ou si vous avez déjà créé le dépôt, entrez l'URL maintenant :"
read -p "URL du dépôt GitHub (ou appuyez sur Entrée pour ignorer): " repo_url

if [ ! -z "$repo_url" ]; then
    echo ""
    echo "🔗 Ajout du remote..."
    git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
    
    echo "🌿 Passage sur la branche main..."
    git branch -M main
    
    echo ""
    read -p "Voulez-vous pousser maintenant ? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📤 Envoi vers GitHub..."
        git push -u origin main
        echo ""
        echo "✅ Projet poussé vers GitHub avec succès !"
    else
        echo "ℹ️  Pour pousser plus tard, exécutez : git push -u origin main"
    fi
fi

echo ""
echo "✨ Terminé !"

