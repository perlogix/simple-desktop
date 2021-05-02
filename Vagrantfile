Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.hostname = "simple-desktop"
  config.vm.network :private_network, ip: "10.20.1.63"
  config.vm.provider "virtualbox" do |v|
    v.name = "simple-desktop"
    v.gui = true
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
    v.customize ["modifyvm", :id, "--memory", 4096, "--cpus", 2, "--vram", 256, "--accelerate3d", "on"]
    v.customize ["setextradata", :id, "GUI/MaxGuestResolution", "any" ]
    v.customize ["setextradata", :id, "CustomVideoMode1", "1024x768x32" ]
    v.customize ["setextradata", :id, "GUI/CustomVideoMode1", "1024x768x32" ]
  end
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get upgrade -y
    apt-get install -y ubuntu-desktop
    cp -f /vagrant/simple-desktop.sh /usr/bin/
    sudo -u vagrant simple-desktop.sh setup
    sudo -u vagrant simple-desktop.sh install theme
    sudo -u vagrant simple-desktop.sh install developer
    sudo -u vagrant simple-desktop.sh install developer
    sudo -u vagrant simple-desktop.sh remove bloat
    sudo -u vagrant simple-desktop.sh install cleanup_script
    reboot
  SHELL
end