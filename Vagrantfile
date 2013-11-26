# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "brewbit-device-server"
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  config.vm.network :forwarded_port, guest: 31337, host: 31337
  config.vm.network :forwarded_port, guest: 10080, host: 10080

  config.vm.provision :chef_solo do |chef|

    chef.data_bags_path = "chef/databags"
    chef.cookbooks_path = "chef/cookbooks"

    chef.add_recipe 'apt'

    # RVM
    chef.add_recipe 'rvm::vagrant'
    chef.add_recipe 'rvm::system'
    chef.add_recipe 'rvm::vagrant'

    # instruct "homesick::data_bag" to install dotfiles for the user 'testuser'
    chef.json = {
      'rvm' => {
        'rubies'       => ['1.9.3-p448'],
        'default_ruby' => '1.9.3-p448',
        'global_gems'  => [
          {'name'    => 'bundler'},
          {'name'    => 'rake', 'version' => '10.1.0'},
          {'name'    => 'pry' }
        ],
        'vagrant' => {
          'system_chef_solo' => '/opt/vagrant_ruby/bin/chef-solo'
        },
        'group_users' => ['vagrant']
      }
    }
  end
end

