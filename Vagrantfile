Vagrant.configure("2") do |config|

    config.vm.box         = "bento/debian-13"
    config.vm.box_version = "202510.26.0"
    config.vm.hostname    = "serveur-tp4"

    # Réseau : cf. séance 3
    config.vm.network "private_network", ip: "192.168.56.40"
    config.vm.network "forwarded_port", guest: 80, host: 8081

    # Pas de dossier partagé : tout passe par le provisionnement
    config.vm.synced_folder ".", "/vagrant", disabled: true

    # Ressources : cf. séance 2
    config.vm.provider "virtualbox" do |vb|
        vb.name   = "vagrant-tp4"
        vb.memory = 2048
        vb.cpus   = 2
    end

    # Dotfiles : partie 3
    config.vm.provision "file", source: "dotfiles/bash_aliases",
                                destination: ".bash_aliases"

    # Provisionnement : partie 4
    config.vm.provision "shell", path: "provisioning/setup.sh"

end
