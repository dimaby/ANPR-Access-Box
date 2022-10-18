FROM nodered/node-red:latest
RUN npm install node-red-contrib-opi-gpio
#USER root
#RUN addgroup gpio
#RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
#RUN apk add -U shadow
#RUN usermod -a -G gpio node-red
#RUN touch /etc/udev/rules.d/99-com.rules
#RUN echo 'KERNEL=="gpio*", RUN="/bin/sh -c '\''chgrp -R gpio /sys/%p /sys/class/gpio && chmod -R g+w /sys/%p /sys/class/gpio/'\''"' >> /etc/udev/rules.d/99-com.rules
#USER node-red