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

cd /root/c0r3/02-workspace/
if [ ! -d live-build-config ]; then
	git clone git://git.kali.org/live-build-config.git
fi


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
bettercap
screenfetch
figlet
terminator
xrdp
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


# Add .bash_rc
cat << EOF > kali-config/common/includes.chroot/root/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -all --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
figlet d43M0n23-C0r3
curl icanhazip.com
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
wget https://github.com/d43M0n23/0wnkali/kali-linux-full-unattended.preseed -O kali-config/common/debian-installer/preseed.cfg


#Let’s include a Nessus Debian package into the packages directory for inclusion into our final build. 
#Since we used a 64 bit build, we’re including a 64 bit Nessus Debian package. 
#Download the Nessus .deb file and place it in the packages.chroot directory:

#mkdir kali-config/common/packages.chroot
#mv Nessus-*amd64.deb kali-config/common/packages.chroot/


# We modify the default Kali preseed which disables normal user creation. 
# We copied this from the debian installer package we initially downloaded.

#mkdir -p config/debian-installer
#cp ../debian-installer-*/build/preseed.cfg config/debian-installer/
#sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
#echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg

# Go ahead and run the build!
lb build
