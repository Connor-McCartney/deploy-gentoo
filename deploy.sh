# https://www.gentoo.org/downloads/
# stage3-amd64-desktop-openrc
STAGE3URL=https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20221211T170150Z/stage3-amd64-desktop-openrc-20221211T170150Z.tar.xz

# fdisk -l
DISK=/dev/sda


date -s "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)" 
printf "g\nn\n1\n\n+256M\nt\n1\nn\n2\n\n+16G\nt\n2\n19\nn\n3\n\n\nw\n" | fdisk $DISK
mkfs.vfat -F 32 "$DISK""1"
mkfs.ext4 "$DISK""3"
mkswap "$DISK""2"
swapon "$DISK""2"
mkdir --parents /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
cd /mnt/gentoo
wget $STAGE3URL
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm -rf stage3-*.tar.xz
