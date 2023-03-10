rm /after-chroot.sh

emerge sys-auth/elogind
rc-update add elogind boot

emerge sys-fs/udev
rc-update add udev sysinit

emerge sys-apps/dbus
rc-update add dbus default

emerge sys-auth/polkit
emerge sys-fs/udisks

rc-update add lvm boot

emerge x11-base/xorg-drivers
emerge dev-libs/wayland

cd /etc/portage
rm make.conf
wget https://raw.githubusercontent.com/Connor-McCartney/deploy-gentoo/main/make2.conf
mv make2.conf make.conf
emerge kde-plasma/plasma-meta
rm make.conf
wget https://raw.githubusercontent.com/Connor-McCartney/deploy-gentoo/main/make.conf

emerge kde-plasma/plasma-pa
emerge konsole
emerge kde-apps/kwalletmanager
emerge kde-misc/bismuth
emerge kde-apps/spectacle
emerge kde-apps/dolphin
emerge kde-apps/ark
emerge dev-vcs/git
emerge dev-util/cmake
emerge dev-python/pip
emerge sys-process/htop
emerge net-libs/nodejs
emerge gui-apps/wl-clipboard
emerge x11-misc/xclip
emerge media-fonts/fonts-meta
emerge net-im/discord-bin
emerge app-admin/keepassxc

rc-update add xdm default
emerge x11-misc/sddm
mkdir -p /etc/sddm/scripts
echo "export \$(dbus-launch) && dbus-run-session startplasma-wayland" > /etc/sddm/scripts/wayland-setup
echo "setxkbmap us" > /etc/sddm/scripts/Xsetup

chmod a+x /etc/sddm/scripts/wayland-setup
chmod a+x /etc/sddm/scripts/Xsetup
printf "[wayland]\nDisplayCommand=/etc/sddm/scripts/wayland-setup\n\n[X11]\nDisplayCommand=/etc/sddm/scripts/Xsetup\n" > /etc/sddm.conf
echo "DISPLAYMANAGER=\"sddm\"" > /etc/conf.d/display-manager
usermod -aG plugdev,sddm connor
