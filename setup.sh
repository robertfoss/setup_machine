#!/bin/sh

RESDIR="/tmp/setup_machine"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

configSudo()
{
    echo "Configuring sudo for $1"
    echo "$1 ALL=(ALL:ALL) ALL" >> /etc/sudoers
}

configSsh()
{
    echo "Configuring ssh"
    sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/.*AuthorizedKeysFile.*/AuthorizedKeysFile %h\/.ssh\/authorized_keys/' /etc/ssh/sshd_config
    sed -i 's/.*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    service ssh restart
}

copyUserFiles()
{
    echo "Copying files to home of $1"
    HOMEDIR=$( getent passwd "$1" | cut -d: -f6 )
    cp "$RESDIR/.bashrc" "$HOMEDIR/"
    cp "$RESDIR/.zshrc" "$HOMEDIR/"
    mkdir -p "$HOMEDIR/.ssh"
    cp "$RESDIR/id_rsa.pu" "$HOMEDIR/.ssh/"
}

setupUser()
{
    if id -u $1 > /dev/null 2>&1; then
        echo "User $1 found"
    else
        echo "User $1 created"
        useradd -m $1 -d /home/$1
        chown -R $1 /home/$1
    fi

    cd
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    copyUserFiles $1
    configSudo $1
}

noFail()
{
    if eval "$@"; then
        :
    else
        echo ""
        echo "Command \"$@\" failed"
        echo ""
        exit 1
    fi
}

noFail apt update
noFail apt install zsh git wget sudo openssh-server

rm -rf ${RESDIR}; git clone https://github.com/robertfoss/setup_machine.git ${RESDIR}

setupUser hottuna
setupUser root

noFail configSsh

echo ""
echo "------"
echo " DONE"
echo "------"
echo ""


