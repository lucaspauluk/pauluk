#!/bin/bash

sudo apt update 

sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

sudo apt update

apt-cache policy docker-ce

sudo apt install docker-ce -y

sudo usermod -aG docker ${USER}

sudo mkdir -p /docker/mysql/wordpress/data
sudo mkdir -p /docker/wordpress/var/www/html

touch /etc/init.d/docker_init_wp.sh
chmod a+x /etc/init.d/docker_init_wp.sh

cat > /etc/init.d/docker_init_wp.sh << EOT
sudo docker start mysql-wordpress &
sudo docker start wordpress &
EOT

meuip=$(hostname -I | awk '{print $1}')

sudo docker pull mysql
sudo docker pull wordpress

docker run -d --name mysql-wordpress \
-p 3306:3306 \
-v /docker/mysql/wordpress/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=secret \
-e MYSQL_DATABASE=wordpress \
-e MYSQL_USER=wordpress \
-e MYSQL_PASSWORD=wordpress \
mysql:5.7

docker run -d --name wordpress \
 -p 80:80 \
 -v /docker/wordpress/var/www/html:/var/www/html \
 -e WORDPRESS_DB_HOST=$meuip \
 -e WORDPRESS_DB_USER="wordpress" \
 -e WORDPRESS_DB_PASSWORD="wordpress" \
 -e WORDPRESS_DB_NAME="wordpress" \
wordpress


