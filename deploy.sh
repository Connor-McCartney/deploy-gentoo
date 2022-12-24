STAGE3URL=https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20221211T170150Z/stage3-amd64-desktop-openrc-20221211T170150Z.tar.xz





# https://www.gentoo.org/downloads/
# stage3-amd64-desktop-openrc
cd /mnt/gentoo
wget $STAGE3URL



# set datetime
date -s "$(wget --method=HEAD -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-10)" 
