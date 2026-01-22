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

# Supprimer les anciennes bases de données
rm -f "${REPO_NAME}.db" "${REPO_NAME}.db.tar.gz" "${REPO_NAME}.db.tar.xz"
rm -f "${REPO_NAME}.files" "${REPO_NAME}.files.tar.gz" "${REPO_NAME}.files.tar.xz"

# Générer la nouvelle base de données
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
# Pacman moderne peut utiliser .db.tar.xz directement, mais certains clients cherchent .db
# Note: Si vous utilisez une URL avec / à la fin dans pacman.conf, pacman devrait trouver .db.tar.xz
# Cette section crée les fichiers .db pour compatibilité
echo -e "${BLUE}Note: Les fichiers .db.tar.xz sont suffisants pour pacman moderne${NC}"
echo -e "${BLUE}Assurez-vous que l'URL dans pacman.conf se termine par / : https://nihil.github.io/\$arch/${NC}"

echo -e "${GREEN}Dépôt mis à jour avec succès!${NC}"
echo -e "${BLUE}Fichiers générés:${NC}"
ls -lh "${REPO_NAME}".db* "${REPO_NAME}".files* 2>/dev/null || true
