#!/bin/bash -e

LABDIR=`pwd`

sudo apt update
sudo apt install -y git nginx mysql-server openjdk-17-jdk maven openssl

git clone https://github.com/Pazinyak18/DatabasesLabs.git -b lab7 lab7

# Setup mysql
# ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'abcEDF123-';
sudo mysql -e "CREATE DATABASE mine"
sudo mysql -e "source lab7/db.sql"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'abcEDF123-';"

sudo service mysql restart

# Setup ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=UA/ST=Lviv/L=Lviv/O=ExampleLtd/CN=localhost"

# Setup nginx
sudo bash -c 'cat >/etc/nginx/sites-available/default' <<EOF
server {
    listen 80;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;
    
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    
    server_name localhost;

    location / {
      proxy_pass http://localhost:8080;
      proxy_set_header Host \$http_host;
    }
}
EOF

sudo service nginx restart

# Get cliend cert
echo quit | openssl s_client -showcerts -servername localhost -connect localhost:443 > cacert.pem



# Setup startup script
sudo bash -c 'cat >/etc/init.d/os-lab' <<EOF
#!/bin/sh

sudo service mysql start
sudo service nginx start

sleep 5
done
EOF

sudo chmod ugoa+x /etc/init.d/os-lab

sudo ln -s /etc/init.d/os-lab /etc/rc3.d/S02os-lab

