********************************** НАЧАЛО УСТАНОВКИ

1) Установка Debian на Orange Pi2 
http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-Zero-2.html

2) BalenaEtcher - Flash SD Card - Orangepizero2_3.0.6_debian_bullseye_server_linux5.16.17

3) Подключаемся через Ethernet

4) Заходим по SSH предварительно посмотрев на роутере какой IP получил мини-сервер, данные для подключения:
ssh root@192.168.87.35
ssh root@192.168.87.34

Логин: root
Пароль: orangepi

5) СТАВИТЬ ---

sudo apt update && sudo apt upgrade -y
sudo apt-get install vim mc screen nmap htop bmon

nmtui (настроить wifi)
orangepi-config

6) СТАВИТЬ --- NGROCK (!ОПЦИЯ! для удаленного доступа)

https://habr.com/ru/amp/post/674070/


curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
      sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
      echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
      sudo tee /etc/apt/sources.list.d/ngrok.list && \
      sudo apt update && sudo apt install ngrok

проверка:
ngrok -h
ngrok authtoken 2IOxbmh8j9Z0bbmUqLJSLuMIksM_4gaT9iM2HMbnqUUR6MoG6
ngrok tcp 22

nano /root/.config/ngrok/ngrok.yml
---
version: "2"
authtoken: 2IOxbmh8j9Z0bbmUqLJSLuMIksM_4gaT9iM2HMbnqUUR6MoG6
tunnels:
    default:
        proto: tcp
        addr: 22
---

Creating a systemd service (Linux - systemd only)

*** в конфигурации сервиса есть ошибки, но он работает, пересмотреть

sudo nano /etc/systemd/system/ngrok.service
---
[Unit]
Description=Ngrok
After=network.service

[Service]
type=simple
ExecStart=/usr/local/bin/ngrok start --all --config="/root/.config/ngrok/ngrok.yml"
Restart=on-failure

[Install]
WantedBy=multi-user.target
---


systemctl enable ngrok.service
systemctl start ngrok.service
systemctl status ngrok.service
systemctl daemon-reload


на маке получить доступ:

nano link2oz2.sh
---
#!/bin/bash

res=$(curl --location --request GET 'https://api.ngrok.com/tunnels' \
--header 'Authorization: Bearer 2IP35mlS0yc7tslLEAHbYqcTkbg_6vRdBB6KoKh9VMJwKz79f' \
--header 'Ngrok-Version: 2' | awk 'BEGIN { FS="\""; RS="," }; { if ($2 == "public_url") {print $4}}')

if [ -z "$res" ]  
then
    echo "No tunnels"
    exit
fi

ip_port=$(echo ${res:6})

arr=($(echo $ip_port | tr ":" "\n"))

ip=$(echo ${arr[0]})
port=$(echo ${arr[1]})

#ssh root@$ip -p $port
sudo ssh -L 80:127.0.0.1:80 -L 81:127.0.0.1:81 -L 82:127.0.0.1:82 root@$ip -p $port
---

запуск автоматического терминал и 80, 81, 82 порты через ngrok (http://localhost/red/,...)
sh link2oz2.sh

проверка ручное подключение:

получить хост и порт
curl --location --request GET 'https://api.ngrok.com/tunnels' --header 'Authorization: Bearer 2IP35mlS0yc7tslLEAHbYqcTkbg_6vRdBB6KoKh9VMJwKz79f' --header 'Ngrok-Version: 2'

терминал через ngrok
ssh root@2.tcp.eu.ngrok.io -p 15123

прокинуть 80 порт
sudo ssh -L 80:localhost:80 root@tcp://0.tcp.eu.ngrok.io -p 17649

админка ngrok:
https://dashboard.ngrok.com/tunnels/agents



7) СТАВИТЬ -- Docker - 
sudo curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

8) СТАВИТЬ -- Docker-compose (https://github.com/docker/compose/releases)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

git clone "https://github.com/dimaby/ANPR-Access-Box.git"
cd ANPR-Access-Box
git pull --force

docker build -t opi-red .

docker-compose build
docker-compose up -d
docker-compose down
docker-compose restart


Сервисы через NGINX:

ip camera:
http://YOUR_IP:81/
admin
EngZDpw2JYfka3W7

hilink:
http://YOUR_IP/

portainer:
http://YOUR_IP/portainer/
admin
adminadminadmin

motioneye:
http://YOUR_IP/motioneye/
admin
no password

red:
http://YOUR_IP/red/

oalprws:
http://YOUR_IP/oalprws/


9) закачать конфигурации для red и motioneye (папка config)


12) НАСТРОИТЬ локальную сеть для камеры RTSP

sudo nano /etc/network/interfaces

---
source /etc/network/interfaces.d/*
# Network is managed by Network manager
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
        address 192.168.1.1
        netmask 255.255.255.0
        gateway 192.168.1.1
---

rtsp://admin:EngZDpw2JYfka3W7@192.168.1.11:554/live/0/MAIN

ffmpeg -y -loglevel error -rtsp_transport udp -i rtsp://admin:EngZDpw2JYfka3W7@192.168.1.11:554/live/0/MAIN -vf "select=bitor(gte(t-prev_selected_t\,2)\,isnan(prev_selected_t))",scale="-1:720" -vsync 0 img_%05d.jpg

ffmpeg -y -loglevel debug -rtsp_transport tcp -i rtsp://admin:Ez9gvE-RJE_m@192.168.87.250 -vframes 1 tcp.jpg
ffmpeg -y -loglevel debug -rtsp_transport udp -i rtsp://admin:Ez9gvE-RJE_m@192.168.87.250 -vframes 1 udp.jpg


http://YOUR_IP:81/ (через NGINX)
http://192.168.87.34:81/


********************************** КОНЕЦ УСТАНОВКИ



--- ЗАМЕТКИ --- 

rm -vrI folder_to_delete

su root
orangepi

--- GPIO ---

id
groups node-red
addgroup gpio
usermod -a -G gpio root

sudo echo 72 > /sys/class/gpio/export
sudo echo out > /sys/class/gpio/gpio72/direction
echo 1 > /sys/class/gpio/gpio72/value

--- ЗАМЕТКИ --- 

http://node-red:1880/api/motionhook

scp ~/reverse_proxy/var_lib_motioneye/Camera1/2022-10-22/19-03-45.jpg user1@192.168.87.163:/Users/user1/Downloads

--- DOCKER BUILD OPENALPR ---

docker build -t openalpr https://github.com/openalpr/openalpr.git
docker run -it --rm -v $(pwd):/data:ro openalpr -c eu Downloads/2.jpg

docker build -t dimaby/oalprws . 
docker run -it --rm -p 8080:8080 dimaby/oalprws

docker tag dimaby/oalprws:latest dimaby/oalprws:latest
docker push dimaby/oalprws:latest

docker pull dimaby/oalprws:latest

http://oalprws:8080/v1/identify/plate


--- RESET PORTAINER PASSWORD --- 

docker container stop portainer
docker run --rm -v ~/reverse_proxy/portainer-data:/data portainer/helper-reset-password
docker container start portainer
Set password rules to weak level.
admin:admin



--- НЕ СТАВИТЬ
--- НЕ СТАВИТЬ
--- НЕ СТАВИТЬ


--- НЕ СТАВИТЬ (Модем для hilink не нужно!)
https://onedev.net/post/904

список подключенных USB модемов -
lsusb | grep Huawei

sudo apt-get install usb-modeswitch usb-modeswitch-data
sudo apt-get install minicom ppp

wget https://netix.dl.sourceforge.net/project/vim-n4n0/sakis3g.tar.gz && tar -xzvf sakis3g.tar.gz && rm sakis3g.tar.gz
sudo chmod +x sakis3g
sudo mv sakis3g /usr/bin/sakis3g

sudo sakis3g --interactive

НЕ СТАВИТЬ -- Python (не ставить, использовать python3)

НЕ СТАВИТЬ -- Portainer (перенесено в docker-compose)
docker pull portainer/portainer-ce
docker volume create portainer_data
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

НЕ СТАВИТЬ -- Red-Node (перенесено в docker-compose)
docker run -d -p 1880:1880 -v node_red_data:/data --name node_red --restart always nodered/node-red


НЕ СТАВИТЬ --- dataplicity (медленно работает! вместо этого NGROCK)