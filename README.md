# WordPress Nginx PHP-fpm with Docker

Deployment orchestrated by Docker Compose.

- Use the FPM version of WordPress
- Use MariaDB as the database
- Use Nginx as the web server
- Use phpMyAdmin as the database management tool
- Include SSL certificate (Design for CloudFlare Origin CA)


## Nginx Config

| File  | Description |
| ------------- | ------------- |
| config/nginx/nginx.conf | The main configuration file for nginx  |
| config/nginx/localhost.conf | nginx server blocks (virtual host) configuration file for localhost (without ssl)  |
| config/nginx/production.conf | nginx server blocks (virtual host) configuration file for production (with ssl certificate) |

## PHP Config

| File  | Description |
| ------------- | ------------- |
| config/php/php.ini | You can modify `php.ini` to override any of the PHP configuration options (eg. memory_limit, upload_max_filesize) |
| config/php/php-fpm.conf | You can modify `php-fpm.conf` to override any of the php-fpm configuration options (eg. pm.max_children, pm.start_servers) |

## Mariadb / MySQL Config

 File  | Description |
| ------------- | ------------- |
| config/mysql/mysqld.cnf | You can modify `mysqld.cnf` to override any of the MySql configuration options (eg. max_connections, query_cache_size)  |

## Docker Compose Environment Variables

You can set default values for environment variables using a `.env` file, which Compose automatically looks for in project directory (parent folder of your Compose file). Values set in the shell environment override those set in the .env file.



```ini
# WordPress Settings
WORDPRESS_LOCAL_PATH=./wordpress
WORDPRESS_DB_HOST=database
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wordpress
WORDPRESS_DB_PASSWORD=password123!

# PHP Settings
PHP_CONFIG=./config/php/php.ini
PHP_FPM_CONFIG=./config/php/php-fpm.conf

# MySQL Settings
MYSQL_CONFIG=./config/mysql/mysqld.cnf
MYSQL_LOCAL_PATH=./data/mysql
MYSQL_DATABASE=${WORDPRESS_DB_NAME}
MYSQL_USER=${WORDPRESS_DB_USER}
MYSQL_PASSWORD=${WORDPRESS_DB_PASSWORD}
MYSQL_ROOT_PASSWORD=rootpassword123!

# Nginx Settings
NGINX_CONF=./config/nginx/nginx.conf
NGINX_SERVER_BLOCK_CONF=./config/nginx/localhost.conf
NGINX_CONFIGS_PATH=./config/nginx/conf
NGINX_SSL_CERTS=./config/nginx/ssl

# Basic Auth Settings
BASIC_AUTH_USER=admin
BASIC_AUTH_PASSWD=admin

```
*For best security practices, it is always recommended that you change the default passwords.

Before docker-compose up starts, Please copy .env.develop or .env.production to .env

For localhost 
```console
cp .env.develop .env
```

For production
```console
cp .env.production .env
```

## For Production with ssl certificate
1. Copy all your ssl certificate files to `./config/nginx/ssl`

2. Please change your server_name and ssl config in `./config/nginx/production.conf`
```conf
    server_name yourdomain.com www.yourdomain.com;

    ssl on;
    ssl_certificate /etc/ssl/your_certificate.crt;
    ssl_certificate_key /etc/ssl/your_private.key;
```
3. Change nginx server block config file to `production.conf` or `production-auth.conf`
```ini
   NGINX_SERVER_BLOCK_CONF=./config/nginx/production.conf
```
## (Optional) Enable basic authentication
Edit environment variable to setup user/password and enable basic authentication for protected wp-login.php & phpmyadmin


```ini
   BASIC_AUTH_USER=admin
   BASIC_AUTH_PASSWD=admin

   NGINX_SERVER_BLOCK_CONF=./config/nginx/localhost-auth.conf
```
Change nginx server block config file to `localhost-auth.conf` or `production-auth.conf`

## (Optional) Enable nginx cache
Input keys_zone to enable cache in a nginx server block config file

```ini
   # Default: fastcgi_cache off;
   fastcgi_cache FASTCGI_CACHE;
```

## Deploy with new WordPress installation page

Once configured the containers can be brought up using Docker Compose

1. Copy env from template file (`.env.develop` or `.env.production`) to `.env`

   ```console
   cp .env.develop .env
   ```

2. Create and start all containers.

   ```console
   docker compose up -d --build
   ```
3. Now let's open a browser and navigate to ‌http://localhost or https://yourdomain The WordPress installation page will welcome you.

## Deploy with your old WordPress website 
1. Copy your wordpress files into `./wordpress` before start Docker Compose.
2. Change file owner to www-data
   ```console
   chown -R www-data:www-data wordpress/
   ```
3. Copy env from template file (`.env.develop` or `.env.production`) to `.env`

   ```console
   cp .env.develop .env
   ```

4. Create and start all containers.

   ```console
   docker compose up -d
   ```
4. Import sql file into database via command line. 
   ```console
   docker exec -i wp-database mysql -u'change_me_user' -p'change_me_passwd' change_me_database_name < backup.sql
   ```

   or \
   You can import sql file into database via phpMyAdmin.

## How can I access to phpMyAdmin?
Browsing to http://localhost/phpmyadmin or https://yourdomain/phpmyadmin

## Backup Script
1. Edit variable in `backup.sh`.
```ini
# Max of backups to keep
max_days=3

# file name prefix
prefix="backup"
```
2. Make it executable.
```console
chmod +x backup.sh
```
3. Insert new cronjob config.
```console
0 1 * * * /your/directory/wordpress-nginx-docker/backup.sh
```
4. After a successful backup finishes, All backup files are stored in `./backup/web` and `./backup/mysql`


## Credits

This repository is inspired by [mjstealey/wordpress-nginx-docker](https://github.com/mjstealey/wordpress-nginx-docker)
