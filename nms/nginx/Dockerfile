FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

COPY add-domain.sh /usr/local/bin/add
COPY remove-domain.sh /usr/local/bin/remove
COPY list-domain.sh /usr/local/bin/list

RUN chmod +x /usr/local/bin/add
RUN chmod +x /usr/local/bin/remove
RUN chmod +x /usr/local/bin/list