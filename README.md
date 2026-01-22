# Dépôt Arch Linux - Nihil

Ce dépôt contient les paquets Arch Linux pour le projet Nihil.

## 📦 Utilisation

### Ajouter le dépôt à votre système

Ajoutez le dépôt à votre fichier `/etc/pacman.conf` :

```ini
[nihil]
SigLevel = Optional TrustAll
Server = https://nihil.github.io/$arch/
```

**Important** : Notez le `/` à la fin de l'URL, c'est important pour que pacman trouve correctement les fichiers.

Ou pour une installation temporaire (sans modification de `/etc/pacman.conf`) :

```bash
sudo pacman -U https://nihil.github.io/x86_64/nihil.db.tar.xz
```

### Synchroniser et installer

```bash
sudo pacman -Sy
sudo pacman -S nihil
```

## 🔧 Développement

### Ajouter un paquet au dépôt

1. Placez votre fichier `.pkg.tar.zst` dans le répertoire `x86_64/`
2. Exécutez le script de mise à jour :

```bash
./update-repo.sh
```

### Avec signature GPG (recommandé)

Si vous avez configuré une clé GPG pour signer vos paquets :

```bash
GPG_KEY="VOTRE_CLE_GPG" ./update-repo.sh
```

### Structure du dépôt

```
nihil.github.io/
├── x86_64/              # Paquets pour architecture x86_64
│   ├── *.pkg.tar.zst    # Paquets Arch Linux
│   ├── nihil.db.tar.xz  # Base de données du dépôt
│   └── nihil.files.tar.xz
├── update-repo.sh       # Script de génération du dépôt
└── README.md            # Ce fichier
```

## 📝 Notes

- Les paquets doivent être au format `.pkg.tar.zst` (recommandé), `.pkg.tar.xz` ou `.pkg.tar.gz`
- Le dépôt est automatiquement mis à jour via GitHub Actions lors des push
- Pour signer les paquets, vous devez avoir configuré une clé GPG

## 🔐 Signature des paquets

Pour signer vos paquets avant de les ajouter au dépôt :

```bash
gpg --detach-sign --default-key VOTRE_CLE package.pkg.tar.zst
```

Puis utilisez `GPG_KEY` lors de l'exécution de `update-repo.sh`.
