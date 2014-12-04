# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

$apt = <<APT
sudo apt-get update
sudo apt-get install -y bundler git libmysqlclient-dev libsqlite3-dev npm nodejs-legacy
APT

$bundler = <<BUNDLER
cd /vagrant
bundle install
BUNDLER

$npm = <<NPM
npm install bower -g
NPM

$bower = <<BOWER
cd /vagrant
echo n | rake bower:install
BOWER

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  config.vm.provision "shell", privileged: true, inline: $apt
  config.vm.provision "shell", privileged: false, inline: $bundler
  config.vm.provision "shell", privileged: true, inline: $npm
  config.vm.provision "shell", privileged: false, inline: $bower
end
