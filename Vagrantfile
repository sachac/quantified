# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: "10.0.0.2"
#  config.vm.provision :shell, :path => 'bootstrap.sh'
  config.vm.provision :chef_solo do |chef|
    chef.roles_path = "chef/roles"
    chef.cookbooks_path = "chef/cookbooks"
    chef.add_role "quantified-box"
  end
end
