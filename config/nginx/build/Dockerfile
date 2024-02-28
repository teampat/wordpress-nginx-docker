FROM nginx:stable

RUN apt-get update -y \
    && apt-get install -y \
        apache2-utils \
    && rm -rf /var/lib/apt/lists/*

ARG BASIC_AUTH_USER BASIC_AUTH_PASSWD

RUN htpasswd -c -b /etc/nginx/auth.htpasswd $BASIC_AUTH_USER $BASIC_AUTH_PASSWD

CMD ["nginx", "-g", "daemon off;"]
