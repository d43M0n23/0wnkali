#!/bin/bash

# Kali Linux ISO recipe for : Top 10 Mate non-root
#########################################################################################
# Desktop 	: Gnome | XFCE
# Metapackages	: kali-linux-top10
# ISO size 	: 1.36 GB 
# Special notes	: root user installation enabled through preseed.cfg. 
#		: This script is not meant to run unattended.
# Look and Feel	: Custom wallpaper and terminal configs through post install hooks.
# Background	: http://www.offensive-security.com/kali-linux/kali-linux-recipes/
#########################################################################################

# Update and install dependencies

apt-get update
apt-get install curl git live-build cdebootstrap devscripts -y

# Clone the default Kali live-build config.

git clone git://git.kali.org/live-build-config.git

# Get the source package of the debian installer. 
# The default Kali preseed file lives here, and will need changing for non-root user support.

#apt-get source debian-installer

# Let's begin our customisations:

cd live-build-config

# The user doesn't need the kali-linux-full metapackage, we overwrite with our own basic packages.
# This includes the debian-installer and the kali-linux-top10 metapackage (commented out for brevity of build, uncomment if needed).

cat > config/package-lists/kali.list.chroot << EOF
kali-root-login
kali-defaults
kali-menu
kali-debtags
kali-archive-keyring
debian-installer-launcher
alsa-tools
locales-all
xorg
#kali-linux-top10
EOF

# Add boot-entry.
cat << EOF > kali-config/common/includes.binary/isolinux/install.cfg
label install
    menu label ^Install Automated
    linux /install/vmlinuz
    initrd /install/initrd.gz
    append vga=788 -- quiet file=/cdrom/install/preseed.cfg locale=de_AT keymap=de hostname=d43M0n23 domain=local.lan
EOF


# SSH service start by default
echo 'systemctl enable ssh' >>  kali-config/common/hooks/01-start-ssh.chroot
chmod +x kali-config/common/hooks/01-start-ssh.chroot


# We download a wallpaper and overlay it.

mkdir -p kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images
#wget https://www.kali.org/dojo/bh2015/wp-blue.png
wget https://3xpl0it.com/c0r3/daemon3.png
mv daemon3.png kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images

# unedetnt install
mkdir -p kali-config/common/debian-installer
wget https://raw.githubusercontent.com/offensive-security/kali-linux-preseed/master/kali-linux-full-unattended.preseed -O kali-config/common/debian-installer/preseed.cfg


#Let’s include a Nessus Debian package into the packages directory for inclusion into our final build. 
#Since we used a 64 bit build, we’re including a 64 bit Nessus Debian package. 
#Download the Nessus .deb file and place it in the packages.chroot directory:

mkdir kali-config/common/packages.chroot
mv Nessus-*amd64.deb kali-config/common/packages.chroot/


# We modify the default Kali preseed which disables normal user creation. 
# We copied this from the debian installer package we initially downloaded.

mkdir -p config/debian-installer
cp ../debian-installer-*/build/preseed.cfg config/debian-installer/
#sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
#echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg

# Go ahead and run the build!
lb build
