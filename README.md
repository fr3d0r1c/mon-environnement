# Mon environnement de travail

Reconstruit une VM Debian 13 avec nginx, prête à l'emploi

## Prérequis
VirtualBox + Vagrant sur l'hôte, box bento/debian-13 version 202510.26.0.

## Usage
    vagrant up          # crée et provisionne
    vagrant ssh         # se connecter
    vagrant destroy -f  # supprimer

Page de test : http://127.0.0.1:8081