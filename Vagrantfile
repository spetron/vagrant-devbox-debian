# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'
vagrantDir = File.expand_path("./vagrant_setup")

settings = YAML.load_file vagrantDir + '/vagrant.yaml'


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "debian/contrib-jessie64"
    config.vm.hostname = settings["box"][0]["name"]
    config.vm.box_check_update = true
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    #config.vm.gui = true
    #config.vm.memory = 2048

    config.vm.network "forwarded_port", guest: 22, host: 2200
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 3306, host: 33306
    config.vm.network "private_network", ip: settings["box"][0]["ip"]


    config.vm.provider :virtualbox do |v|
       v.customize ['modifyvm', :id, '--name',   settings["box"][0]["name"]]
       v.customize ['modifyvm', :id, '--memory', settings["box"][0]["memory"]]
    end

    config.vm.provision "shell" do |s|
        s.path = vagrantDir + '/bootstrap.sh'
        s.args = [
                    settings["box"][0]["host"],
                    settings["box"][0]["ip"],
                    settings["box"][0]["datetimezone"],
                    settings["mysql"][0]["rootuser"],
                    settings["mysql"][0]["rootpass"]
                 ]
    end

#    config.vm.provision :shell, run: "always", :path => "load.sh"

    settings["folders"].each do |folder|
        config.vm.synced_folder folder["map"], folder["to"], type: "virtualbox", owner: "www-data", group: "www-data"
    end



    settings["sites"].each do |site|
      config.vm.provision "shell" do |s|
        s.path = vagrantDir + "/apache-vhost-setup.sh"
        s.args = [
                    settings["box"][0]["ip"],
                    site["host"],
                    site["folder"],
                    site["port"] ||= "80",
                    site["ssl"] ||= "443"
                  ]
      end

      config.vm.provision "shell" do |s|
        s.inline = "service apache2 restart"
      end
    end


#######################################################
    # Configure All Of The Configured Databases
    if settings.has_key?("mysql_dbs")
        settings["mysql_dbs"].each do |db|

          config.vm.provision "shell" do |s|
            s.path = vagrantDir + "/mysql-db-setup.sh"
            s.args = [
                db["name"],
                db["user"],
                db["pass"],
                settings["mysql"][0]["rootuser"],
                settings["mysql"][0]["rootpass"]
            ]
          end

          config.vm.provision "shell" do |s|
            s.path = vagrantDir + "/mysql-db-import.sh"
            s.args = [
                db["name"],
                db["user"],
                db["pass"],
                db["file"],
                settings["mysql"][0]["rootuser"],
                settings["mysql"][0]["rootpass"]
            ]
          end

        end
    end
#######################################################


#######################################################
    # Configure All Of The Configured Databases
    if settings.has_key?("postgresql_dbs")
        settings["postgresql_dbs"].each do |db|
          config.vm.provision "shell" do |s|
            s.path = vagrantDir + "/postgresql-db-setup.sh"
            s.args = [
                db["name"],
                db["user"],
                db["pass"],
                settings["postgresql"][0]["rootuser"],
                settings["postgresql"][0]["rootpass"]
            ]
          end

          config.vm.provision "shell" do |s|
            s.path = vagrantDir + "/postgresql-db-import.sh"
            s.args = [
                db["name"],
                db["user"],
                db["pass"],
                db["file"],
                settings["postgresql"][0]["rootuser"],
                settings["postgresql"][0]["rootpass"]
            ]
          end

        end
    end
#######################################################


#   # Update Composer On Every Provision
#    config.vm.provision "shell" do |s|
#      s.inline = "/usr/local/bin/composer self-update"
#    end




    # Configure Blackfire.io
    if settings.has_key?("blackfire")
      config.vm.provision "shell" do |s|
        s.path = vagrantDir + "/blackfire.sh"
        s.args = [
          settings["blackfire"][0]["id"],
          settings["blackfire"][0]["token"],
          settings["blackfire"][0]["client-id"],
          settings["blackfire"][0]["client-token"]
        ]
      end
    end


#   config.vm.provision :ansible do |ansible|
#       ansible.playbook = 'setup.yml'
#       ansible.inventory_path = 'hosts'
#       ansible.limit = 'all'
#   end

#   eval(File.open("#{Dir.home}/path/to/vagrant/project/Vagrantfile").read)
end
