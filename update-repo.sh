#!/bin/bash
# Script pour générer et mettre à jour le dépôt Arch Linux

set -e

REPO_NAME="nihil"
REPO_DIR="x86_64"
GPG_KEY="${GPG_KEY:-}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[NIHIL] Mise à jour du dépôt Arch Linux${NC}"

# Vérifier que repo-add est disponible
if ! command -v repo-add &> /dev/null; then
    echo -e "${RED}Erreur: repo-add n'est pas installé. Installez pacman-contrib.${NC}"
    exit 1
fi

# Vérifier que le répertoire existe
if [ ! -d "$REPO_DIR" ]; then
    echo -e "${RED}Erreur: Le répertoire $REPO_DIR n'existe pas.${NC}"
    exit 1
fi

# Déplacer les paquets de la racine vers x86_64/ si nécessaire
ROOT_PKGS=$(find . -maxdepth 1 \( -name "*.pkg.tar.zst" -o -name "*.pkg.tar.xz" -o -name "*.pkg.tar.gz" \) 2>/dev/null | wc -l)
if [ "$ROOT_PKGS" -gt 0 ]; then
    echo -e "${BLUE}Déplacement de $ROOT_PKGS paquet(s) de la racine vers $REPO_DIR/${NC}"
    find . -maxdepth 1 \( -name "*.pkg.tar.zst" -o -name "*.pkg.tar.xz" -o -name "*.pkg.tar.gz" \) -exec mv {} "$REPO_DIR/" \; 2>/dev/null || true
fi

cd "$REPO_DIR"

# Compter les paquets
PKG_COUNT=$(find . -maxdepth 1 \( -name "*.pkg.tar.zst" -o -name "*.pkg.tar.xz" -o -name "*.pkg.tar.gz" \) | wc -l)

if [ "$PKG_COUNT" -eq 0 ]; then
    echo -e "${RED}Aucun paquet trouvé dans $REPO_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Nombre de paquets trouvés: $PKG_COUNT${NC}"

# Supprimer les anciennes bases de données (tous les formats)
rm -f "${REPO_NAME}.db" "${REPO_NAME}.db.tar.gz" "${REPO_NAME}.db.tar.xz"
rm -f "${REPO_NAME}.files" "${REPO_NAME}.files.tar.gz" "${REPO_NAME}.files.tar.xz"

# Générer la nouvelle base de données en format .tar.xz
if [ -n "$GPG_KEY" ]; then
    echo -e "${BLUE}Signature avec la clé GPG: $GPG_KEY${NC}"
    repo-add -s -k "$GPG_KEY" "${REPO_NAME}.db.tar.xz" *.pkg.tar.* 2>/dev/null || \
    repo-add -s -k "$GPG_KEY" "${REPO_NAME}.db.tar.xz" *.pkg.tar.*
else
    echo -e "${BLUE}Génération du dépôt sans signature${NC}"
    repo-add "${REPO_NAME}.db.tar.xz" *.pkg.tar.* 2>/dev/null || \
    repo-add "${REPO_NAME}.db.tar.xz" *.pkg.tar.*
fi

# Créer aussi les fichiers .db et .files non compressés (nécessaires pour que pacman les trouve)
echo -e "${BLUE}Création des fichiers .db et .files non compressés${NC}"
rm -f "${REPO_NAME}.db" "${REPO_NAME}.files"

# Extraire et reconstruire le fichier .db
TEMP_DIR=$(mktemp -d)
CURRENT_DIR=$(pwd)
cd "$TEMP_DIR"
tar -xf "${CURRENT_DIR}/${REPO_NAME}.db.tar.xz" 2>/dev/null
# Concaténer tous les fichiers desc dans l'ordre
find . -name "desc" -type f | sort | xargs cat > "${CURRENT_DIR}/${REPO_NAME}.db" 2>/dev/null
cd "$CURRENT_DIR"
rm -rf "$TEMP_DIR"

# Extraire et reconstruire le fichier .files
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
tar -xf "${CURRENT_DIR}/${REPO_NAME}.files.tar.xz" 2>/dev/null
# Concaténer tous les fichiers files dans l'ordre
find . -name "files" -type f | sort | xargs cat > "${CURRENT_DIR}/${REPO_NAME}.files" 2>/dev/null
cd "$CURRENT_DIR"
rm -rf "$TEMP_DIR"

# Vérifier que les fichiers ont été créés
if [ ! -f "${REPO_NAME}.db" ] || [ ! -s "${REPO_NAME}.db" ]; then
    echo -e "${RED}Erreur: Le fichier .db n'a pas pu être créé${NC}"
    exit 1
fi

if [ ! -f "${REPO_NAME}.files" ] || [ ! -s "${REPO_NAME}.files" ]; then
    echo -e "${RED}Erreur: Le fichier .files n'a pas pu être créé${NC}"
    exit 1
fi

echo -e "${GREEN}Fichiers .db et .files créés avec succès${NC}"

echo -e "${GREEN}Dépôt mis à jour avec succès!${NC}"
echo -e "${BLUE}Fichiers générés:${NC}"
ls -lh "${REPO_NAME}".db* "${REPO_NAME}".files* 2>/dev/null || true

echo -e "${BLUE}Prochaines étapes:${NC}"
echo -e "1. Vérifiez les fichiers: ls -lh x86_64/nihil.*"
echo -e "2. Ajoutez-les à git: git add x86_64/nihil.* x86_64/*.pkg.tar.zst"
echo -e "3. Commitez: git commit -m 'Mise à jour du dépôt'"
echo -e "4. Pushez: git push"
echo -e "5. Vérifiez l'URL: https://nihil.github.io/x86_64/nihil.db"
