# https://www.gentoo.org/downloads/
# stage3-amd64-desktop-openrc
STAGE3URL=https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20221211T170150Z/stage3-amd64-desktop-openrc-20221211T170150Z.tar.xz

# https://packages.gentoo.org/packages/sys-kernel/gentoo-kernel-bin
KERNEL="sys-kernel/gentoo-kernel-bin:5.15.83"

# fdisk -l
DISK=/dev/sda

# eselect profile list
DESKTOP=9

HOSTNAME="gentoo"

# ip a
INTERFACE="wlan0"


date -s "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)" 
printf "g\nn\n1\n\n+256M\nt\n1\nn\n2\n\n+16G\nt\n2\n19\nn\n3\n\n\nw\n" | fdisk $DISK
mkfs.vfat -F 32 "$DISK""1"
mkfs.ext4 "$DISK""3"
mkswap "$DISK""2"
swapon "$DISK""2"
mkdir --parents /mnt/gentoo
mount "$DISK""3" /mnt/gentoo
cd /mnt/gentoo
wget $STAGE3URL
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm -rf stage3-*.tar.xz
cd /mnt/gentoo/etc/portage
rm make.conf
wget https://raw.githubusercontent.com/Connor-McCartney/deploy-gentoo/main/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

chroot /mnt/gentoo /bin/bash
source /etc/profile
mount "$DISK""1" /boot
emerge-webrsync
emerge --sync
eselect profile set $DESKTOP
emerge --verbose --update --deep --newuse @world


emerge gui-apps/wl-clipboard
emerge x11-misc/xclip
emerge app-editors/neovim
emerge $KERNEL
emerge sys-apps/pciutils
emerge sys-kernel/linux-firmware
emerge net-misc/dhcpcd
emerge net-wireless/wpa_supplicant
emerge sys-boot/grub
emerge app-admin/sudo
emerge app-misc/neofetch


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
