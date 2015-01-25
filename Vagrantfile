# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.6.0'
Vagrant.configure(2) do |config|
  config.vm.define 'iso8601' do |c|
    c.vm.box = "coreos-alpha"
    c.vm.box_version = '>= 561.0.0'
    c.vm.box_url = "http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

    c.vm.network :private_network, ip: '10.10.1.100'
    # Allows dynamic synced folders with docker as it seems Vagrant doesn't
    # work well with coreOS (?)
    c.vm.synced_folder '.', '/home/core/share', {
      id: 'core',
      nfs: true,
      mount_options: ['nolock,vers=3,udp']
    }

    c.vm.provider :virtualbox do |vb|
      vb.check_guest_additions = false
      vb.functional_vboxsf = false
      vb.memory = 1024
      vb.cpus = 1
      vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    end
  end

  config.vm.define 'mri-2.2' do |c|
    c.vm.provider 'docker' do |d|
      d.vagrant_machine = 'iso8601'
      d.vagrant_vagrantfile = './Vagrantfile'
      d.build_dir = '.'
      d.build_args = ['-t', 'arnau/iso8601:2.2']
      d.create_args = [
        '-v', '/home/core/share:/usr/src/iso8601',
      ]
      d.remains_running = false
    end
  end
end
