#!/bin/bash

# fdisk -l
DISK=/dev/sda

# ip a
INTERFACE="wlan0"




source /etc/profile
mount "$DISK""1" /boot
emerge-webrsync
emerge --sync
eselect profile set 9
emerge --verbose --update --deep --newuse @world

emerge app-editors/neovim
emerge $KERNEL
emerge sys-apps/pciutils
emerge sys-kernel/linux-firmware
emerge net-misc/dhcpcd
emerge net-wireless/wpa_supplicant
emerge sys-boot/grub
emerge app-admin/sudo

echo "Australia/Brisbane" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set 4 # (US one just made)
env-update && source /etc/profile

cd /etc
rm fstab
wget https://raw.githubusercontent.com/Connor-McCartney/deploy-gentoo/main/fstab
echo $HOSTNAME > /etc/conf.d/hostname
emerge --noreplace net-misc/netifrc 
printf "config_$INTERFACE=\"dhcp\"\nmodules_$INTERFACE=\"wpa_supplicant\"\n" > /etc/conf.d/net
cd /etc/init.d
ln -s net.lo net.$INTERFACE
rc-update add net.$INTERFACE default
rc-service net.$INTERFACE start
rc-service dhcpcd start

grub-install $DISK # legacy
# grub-install --target=x86_64-efi --efi-directory=/boot # UEFI
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -G users,wheel,audio,plugdev,video,sddm -s /bin/bash connor



# Manual todo

# visudo # uncomment wheel ALL=(ALL:ALL) ALL
# nvim /etc/security/passwdqc.conf # enforce=none
# passwd connor
# nvim /etc/wpa_supplicant/wpa_supplicant.conf
