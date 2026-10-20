# TP4 — Réponses aux questions

## Question 1 — Quatre réglages faits à la souris aux séances 2 et 3

| Ligne du Vagrantfile | Où je l'avais fait dans l'interface |
| --- | --- |
| `config.vm.network "private_network", ip: "192.168.56.40"` | TP3 : Configuration → Réseau → Carte 2 → Réseau privé hôte (vboxnet0), puis adresse fixe avec `nmcli` dans la VM |
| `config.vm.network "forwarded_port", guest: 80, host: 8081` | TP3 : Configuration → Réseau → Carte 1 (NAT) → Avancé → Redirection de ports |
| `vb.memory = 2048` et `vb.cpus = 2` | Configuration → Système → Carte mère (mémoire vive) et Processeur |
| `config.vm.hostname = "serveur-tp4"` | TP2 : dans le clone, `sudo hostnamectl set-hostname debian-clone` |

## Question 2 — La VM apparaît-elle dans VirtualBox ?

Oui, `vagrant-tp4` apparaît dans la liste de VirtualBox comme n'importe quelle VM. Vagrant n'est donc pas un hyperviseur : c'est un outil qui pilote VirtualBox à ma place (création, réseau, ressources, démarrage), à partir de la description du `Vagrantfile`.

## Question 3 — Le dossier `.vagrant/`

Il contient l'état local de Vagrant pour cette machine, dans `.vagrant/machines/default/virtualbox/` : l'identifiant de la VM dans VirtualBox (`id`), des informations de provisionnement et surtout `private_key`, la clé SSH privée qui ouvre la VM. `git status` ne le montre pas car il est listé dans `.gitignore`. Il ne faut jamais le transmettre : la clé privée donnerait accès à ma machine, et cet état ne vaut que pour mon poste (l'UUID de VM n'existe pas ailleurs).

## Question 4 — `vagrant provision` relancé deux fois

Non, le fichier d'alias n'est pas dupliqué : `~/.bash_aliases` contient toujours une seule fois chaque alias. Le provisionneur `file` copie le fichier entier et écrase la destination : quel que soit le nombre d'exécutions, l'état final est le même fichier.

## Question 5 — Idempotence du script

Après trois provisionnements, `export EDITOR` apparaît **1 fois** dans `/etc/profile` (résultat de ma commande : 1).

Les trois motifs :

1. **Page web** — `cat > /var/www/html/index.html <<'HTML'` : la redirection `>` écrase le fichier au lieu d'ajouter, donc le contenu final est toujours identique.
2. **Étape 5** — `id -u devops >/dev/null 2>&1 || useradd -m -s /bin/bash devops` : on teste d'abord si l'utilisateur existe, et `useradd` n'est lancé que si le test échoue.
3. **Étape 6** — `grep -qxF "$LIGNE" /etc/profile || echo "$LIGNE" >> /etc/profile` : on cherche la ligne exacte, et on ne l'ajoute que si elle est absente.

## Question 6 — Pourquoi le compteur ne redescend pas après `git restore`

Avec la version naïve, chaque provisionnement a ajouté une ligne de plus dans `/etc/profile` de la VM (compteur obtenu : `3`). `git restore` a réparé la **recette** (le fichier `setup.sh` sur l'hôte), mais pas la **machine** : les lignes déjà écrites dans la VM y restent. Le script idempotent évite d'ajouter une ligne, il n'enlève pas les doublons. La commande qui remet la machine d'aplomb est `vagrant destroy -f` suivie de `vagrant up` : on repart d'une VM neuve, construite à partir de la recette corrigée.

## Question 7 — Sans `config.vm.box_version`

Vagrant prendrait la dernière version disponible de `bento/debian-13`. Dans un an, ce ne serait plus la même image : autres versions de paquets, autre noyau, réglages par défaut différents. Le script pourrait alors se comporter autrement ou échouer, et la machine ne serait plus reproductible à l'identique. Épingler la version garantit que tout le monde, et moi plus tard, part de la même base.

## Question 8 — Reconstruction depuis une copie fraîche

La reconstruction complète a pris 1 min 34, contre environ 45 minutes d'installation manuelle au TP1. L'écart vient de la box : Debian est déjà installée, il n'y a ni installateur ni questions, et le script enchaîne tout seul la configuration sans attendre un humain. Le compteur vaut maintenant **1** (résultat : 1) : la VM est neuve, construite depuis une box propre avec le script idempotent du dépôt, donc les doublons de la question 6 ont disparu avec l'ancienne machine.