#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive   # aucune question pendant apt

echo "=== Provisionnement : début ==="

# --- 1. Paquets ------------------------------------------------------------
# apt-get install est naturellement idempotent : si le paquet est là, il ne
# fait rien. On note quand même la liste, pour qu'elle soit relisable.
PAQUETS="nginx curl ufw"
apt-get update -qq
apt-get install -y -qq $PAQUETS

# --- 2. Page web ------------------------------------------------------------
# On ÉCRASE le fichier (>) plutôt que d'y ajouter (>>) : l'état final est
# toujours le même, quel que soit le nombre d'exécutions.
cat > /var/www/html/index.html <<'HTML'
<!doctype html>
<html lang="fr">
<head><meta charset="utf-8"><title>Environnement reproductible</title></head>
<body style="font-family:sans-serif;max-width:40em;margin:4em auto">
<h1>Machine reconstruite par Vagrant</h1>
<p>Si vous lisez ceci, l'environnement a été recréé à partir de mon dépôt.</p>
<p>TP4 &middot; Frédéric ALLERON</p>
</body>
</html>
HTML

# --- 3. Service ------------------------------------------------------------
# enable --now : active au démarrage ET démarre maintenant. Rejouable.
systemctl enable --now nginx

# --- 4. Pare-feu ------------------------------------------------------------
# ufw allow est idempotent (il dit "Skipping adding existing rule").
ufw --force default deny incoming
ufw --force default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw --force enable

# --- 5. Un utilisateur, SANS échouer s'il existe déjà ----------------------
# Le test `id ... ||` est le motif d'idempotence à retenir.
id -u devops >/dev/null 2>&1 || useradd -m -s /bin/bash devops
# --- 6. Une ligne dans un fichier, UNE SEULE FOIS --------------------------
LIGNE="export EDITOR=nano"
grep -qxF "$LIGNE" /etc/profile || echo "$LIGNE" >> /etc/profile
echo "=== Provisionnement : terminé ==="