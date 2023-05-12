FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

RUN apk update && apk add curl net-tools

RUN IP=$(curl -s ifconfig.me) && \
    sed -i "s/Node_Multiple_Simple/$IP/g" /usr/share/nginx/html/index.html

COPY .add-domain.sh /usr/local/bin/add
COPY .remove-domain.sh /usr/local/bin/remove
COPY .list-domain.sh /usr/local/bin/list

RUN chmod +x /usr/local/bin/add
RUN chmod +x /usr/local/bin/remove
RUN chmod +x /usr/local/bin/list