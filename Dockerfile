FROM nginx:alpine

RUN apk add --no-cache bash openssl curl
RUN mkdir -p /etc/nginx/ssl
RUN rm -f /etc/nginx/conf.d/*.conf

COPY conf.d/f5demo.nginx.conf.template /etc/nginx/conf.d/
COPY conf.d/f5demo.js /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/nginx.conf

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ADD html /usr/share/nginx/html
COPY html/_ /usr/share/nginx/html/_.html

EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]