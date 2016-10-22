#!/bin/bash

# Description:
#
#     This bash script is used to provision the virtualbox that vagrant creates.
#     I.e., it installs and configures stuff; and also deals with updating and
#     upgrading.
#
#     NOTE that this is run within the virtualbox! That means that, for example,
#     the paths to files you see in this script are from the perspective of
#     someone (or something) on the virtualbox.
#
#     One consequence of that is that to access files in this directory (or a
#     sub-subdirectory of this directory, etc) that these are found under the
#     /vagrant directory.
#



#
# M A I N
#

set -e
export DEBIAN_FRONTEND=noninteractive

echo "############################################################"
echo "#                                                          #"
echo "# Starting provisioning script...                          #"
echo "#                                                          #"
echo "############################################################"
echo
echo

echo "############################################################"
echo "#                                                          #"
echo "# Add PostgreSql Repos                                     #"
echo "#                                                          #"
echo "############################################################"
echo
echo
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

echo "############################################################"
echo "#                                                          #"
echo "# Add HAProxy Repo                                         #"
echo "#                                                          #"
echo "############################################################"
echo
echo
add-apt-repository ppa:vbernat/haproxy-1.6

echo "############################################################"
echo "#                                                          #"
echo "# apt-get -y update                                        #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y update

echo "############################################################"
echo "#                                                          #"
echo "# apt-get install haproxy                                  #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install haproxy

echo "############################################################"
echo "#                                                          #"
echo "# apt-get install acl                                      #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get install -y acl

echo "############################################################"
echo "#                                                          #"
echo "# apt-get install postgresql-9.5                           #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install postgresql-9.5

echo "############################################################"
echo "#                                                          #"
echo "# apt-get -y install finger                                #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install finger

echo "############################################################"
echo "#                                                          #"
echo "# apt-get -y install tree                                  #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install tree

echo "############################################################"
echo "#                                                          #"
echo "# apt-get -y install curl                                  #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install curl

echo "############################################################"
echo "#                                                          #"
echo "# apt-get -y install git                                   #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install git

echo "############################################################"
echo "#                                                          #"
echo "# Installing Go                                            #"
echo "#                                                          #"
echo "############################################################"
echo
echo
#GOLANG_TARBALL='go1.7.linux-386.tar.gz'
GOLANG_TARBALL='go1.7.linux-amd64.tar.gz'
pushd /usr/local/
wget "https://storage.googleapis.com/golang/${GOLANG_TARBALL}"
tar -zxvf "${GOLANG_TARBALL}"
rm -f "${GOLANG_TARBALL}"
popd
pushd /home/vagrant
mkdir -p bin
chown vagrant.vagrant bin
cd bin
ln -s /usr/local/go/bin/go    go
ln -s /usr/local/go/bin/godoc godoc
ln -s /usr/local/go/bin/gofmt gofmt
popd

echo "############################################################"
echo "#                                                          #"
echo "# Creating /usr/local/golang                               #"
echo "#                                                          #"
echo "############################################################"
echo
echo
mkdir /usr/local/golang

echo "############################################################"
echo "#                                                          #"
echo "# Installing go syntax for vim                             #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y install vim-gocomplete gocode vim-syntax-go
vim-addon-manager install go-syntax
vim-addon-manager install gocode

echo "############################################################"
echo "#                                                          #"
echo "# Installing glide                                         #"
echo "#                                                          #"
echo "############################################################"
echo
echo
add-apt-repository ppa:masterminds/glide && sudo apt-get update
apt-get install glide

# set permissions
# this is needed on a real server, but not Vagrant
#setfacl -Rm u:ubuntu:rwX,d:u:ubuntu:rwX /srv/web/bin
#setfacl -Rm rwX,u:ubuntu:rwX,d:u:ubuntu:rwX /srv/web/bin

echo "############################################################"
echo "#                                                          #"
echo "# Postgres: Setting up default user and database           #"
echo "#                                                          #"
echo "############################################################"
echo
echo
# configure the default postgres user
echo "ALTER USER postgres WITH PASSWORD 'postgres';" | sudo -u postgres psql

if [[ `echo "SELECT 1 FROM pg_database WHERE datname='myproject';" | sudo -u postgres psql -tA` != "1" ]]
then
    # create the database
    echo "CREATE DATABASE myproject;" | sudo -u postgres psql
fi

echo "############################################################"
echo "#                                                          #"
echo "# apt-get autoremove                                       #"
echo "#                                                          #"
echo "############################################################"
echo
echo
apt-get -y autoremove

echo "############################################################"
echo "#                                                          #"
echo "# Add 'cd /srv/web' and $GOPATH to /home/vagrant/.profile  #"
echo "#                                                          #"
echo "############################################################"
echo
echo
grep -q -F 'cd /srv/web' /home/vagrant/.profile || echo 'cd /srv/web' >> /home/vagrant/.profile
grep -q -F 'export GOPATH=/srv/web' /home/vagrant/.profile || echo 'export GOPATH=/srv/web' >> /home/vagrant/.profile

echo "############################################################"
echo "#                                                          #"
echo "# HAProxy config and start                                 #"
echo "#                                                          #"
echo "############################################################"
echo
echo
sudo ln -sf /srv/web/vagrant/haproxy.cfg /etc/haproxy/haproxy.cfg
service haproxy restart

echo "############################################################"
echo "#                                                          #"
echo "# And... we are done.                                      #"
echo "#                                                          #"
echo "############################################################"
echo
echo
