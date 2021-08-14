snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
cat << EOF > /etc/apt/sources.list.d/nginx.list
deb https://nginx.org/packages/ubuntu/ focal nginx
deb-src https://nginx.org/packages/ubuntu/ focal nginx
EOF
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get install nginx -y
reboot