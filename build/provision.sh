gm#!/bin/bash
#
# Exit on errors or unitialized variables
#
set -e -o nounset


# Add GPG key, install packages and update
#
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum remove -y vim-minimal
yum install -y sudo vim nano docker-io cmake mongodb
yum update -y


# Configure and start docker daemon
#
groupadd docker || true
gpasswd -a vagrant docker
systemctl enable docker
systemctl start docker


# Pass commands as vagrant user, not root
#
#su vagrant << EOF
  # Add dockin() function to .bashrc
  #
  if(! grep --quiet 'function dockin()' /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Function to make nsenter easier' | tee -a /home/vagrant/.bashrc
    echo '#' | tee -a /home/vagrant/.bashrc
    echo 'function dockin()' | tee -a /home/vagrant/.bashrc
    echo '{' | tee -a /home/vagrant/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a /home/vagrant/.bashrc
    echo '  then' | tee -a /home/vagrant/.bashrc
    echo '		echo "Please pass a docker container to enter"' | tee -a /home/vagrant/.bashrc
    echo '		echo "Usage: dockin [containerToEnter]"' | tee -a /home/vagrant/.bashrc
    echo '	else' | tee -a /home/vagrant/.bashrc
    echo '		sudo nsenter --target $(docker inspect --format {{.State.Pid}} $1) --mount --uts --ipc --net --pid /bin/bash' | tee -a /home/vagrant/.bashrc
    echo '	fi' | tee -a /home/vagrant/.bashrc
    echo '}' | tee -a /home/vagrant/.bashrc

  if(! grep --quiet 'function reload()' /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Function to make container rebuilds easier' | tee -a /home/vagrant/.bashrc
    echo '#' | tee -a /home/vagrant/.bashrc
    echo 'function reload()' | tee -a /home/vagrant/.bashrc
    echo '{' | tee -a /home/vagrant/.bashrc
    echo '  if [ $# -eq 0 ]' | tee -a /home/vagrant/.bashrc
    echo '  then' | tee -a /home/vagrant/.bashrc
    echo '    echo "Please pass a docker container to destroy and recreate"' | tee -a /home/vagrant/.bashrc
    echo '    echo "Usage: reload [containerToReload]"' | tee -a /home/vagrant/.bashrc
    echo '  else' | tee -a /home/vagrant/.bashrc
    echo '    docker rm -fv $1' | tee -a /home/vagrant/.bashrc
    echo '    make build-$1' | tee -a /home/vagrant/.bashrc
    echo '    make run-$1' | tee -a /home/vagrant/.bashrc
    echo '  fi' | tee -a /home/vagrant/.bashrc
    echo '}' | tee -a /home/vagrant/.bashrc
  fi

  if(! grep --quiet "alias c='dockin'" /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Aliases to frequently used functions and applications' | tee -a /home/vagrant/.bashrc
    echo '#' | tee -a /home/vagrant/.bashrc
    echo "alias c='dockin'" | tee -a /home/vagrant/.bashrc
    echo "alias d='docker'" | tee -a /home/vagrant/.bashrc
    echo "alias r='reload'" | tee -a /home/vagrant/.bashrc
    echo "alias l='docker logs'" | tee -a /home/vagrant/.bashrc
  fi

  # Start in /vagrant/, instead of /home/vagrant/
  if(! grep --quiet 'cd /vagrant/' /home/vagrant/.bashrc)
  then
    echo '' | tee -a /home/vagrant/.bashrc
    echo '# Start in /vagrant/, instead of /home/vagrant/' | tee -a /home/vagrant/.bashrc
    echo 'cd /vagrant/' | tee -a /home/vagrant/.bashrc
  fi
#EOF


# Make containers
#
cd /vagrant/build/docker
make
