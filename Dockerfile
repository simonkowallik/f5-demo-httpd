FROM nginx:alpine

RUN apk add --no-cache bash openssl curl
RUN mkdir -p /etc/nginx/ssl
RUN rm -f /etc/nginx/conf.d/*.conf

COPY files/conf.d/f5demo.nginx.conf.template /etc/nginx/conf.d/
COPY files/conf.d/f5demo.js /etc/nginx/conf.d/
COPY files/nginx.conf /etc/nginx/nginx.conf

ADD files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ADD files/html /usr/share/nginx/html
COPY files/html/_ /usr/share/nginx/html/_.html

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]