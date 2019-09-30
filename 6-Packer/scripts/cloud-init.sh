#! /bin/bash

#Remove this script once Centos 7.6 is targeted from the marketplace as it will come with cloud-init pre-installed
#Derived from  https://github.com/danielsollondon/azcloud-init/blob/master/centOS76_cloud-init_image_config.md

sudo yum makecache fast
echo "install cloud-init dependencies"
sudo yum install -y gdisk cloud-utils-growpart
sudo echo install of cloud-init
sudo yum install -y cloud-init

echo "configure the cloud.cfg"
sudo sed -i '/ - mounts/d' /etc/cloud/cloud.cfg
sudo sed -i '/ - disk_setup/d' /etc/cloud/cloud.cfg
sudo sed -i '/cloud_init_modules/a\\ - mounts' /etc/cloud/cloud.cfg
sudo sed -i '/cloud_init_modules/a\\ - disk_setup' /etc/cloud/cloud.cfg

echo "configure the cloud.cfg"
sudo cloud-init clean

echo "waagent provisioning config turned off"
sudo sed -i 's/Provisioning.Enabled=y/Provisioning.Enabled=n/g' /etc/waagent.conf
sudo sed -i 's/Provisioning.UseCloudInit=n/Provisioning.UseCloudInit=y/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf
        
echo "removing swapfile - oralinux uses a swapfile by default"
swapoff /mnt/resource/swapfile
rm /mnt/resource/swapfile -f

echo "Set DS properties - not setting this causes 2s delay"
sudo bash -c 'cat > /etc/cloud/cloud.cfg.d/91-azure_datasource.cfg' <<EOF
# This configuration file is used to connect to the Azure DS sooner
datasource_list: [ Azure ]
EOF