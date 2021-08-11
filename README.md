# WebRuntime Containers

## Flavours

| Flavour                    | Toolchain                                                      |
| -------------------------- | -------------------------------------------------------------- |
| `ubuntu-20.04`, _`latest`_ | apache: 2.4; php: 7.4; composer: 1, 2; node: 14.x; python: 3.8 |
| `ubuntu-20.04-dev`         |                                                                |
| `ubuntu-18.04`             | apache: 2.4; php: 7.2; composer: 1, 2; node: 12.x; python: 3.6 |
| `ubuntu-18.04-dev`         |                                                                |
| `ubuntu-14.04`             | apache: 2.4; php: 5.5; composer: 1; node: 10.x; python: 3.4    |
| `ubuntu-14.04-dev`         |                                                                |
| `ubuntu-12.04`             | apache: 2.2; php: 5.3; composer: 1; node: 8.x; python: 2.7     |
| `ubuntu-12.04-dev`         |                                                                |
| `alpine-php8`              | apache: 2.4; php: 8.0; composer: 2; node: 14.x; python: 3.9    |
| `alpine-php8-dev`          |                                                                |
| `alpine`                   | apache: 2.4; php: 7.4; composer: 2; node: 14.x; python: 3.9    |
| `alpine-dev`               |                                                                |

## Whats inside?

-   Apache
-   PHP (with composer-1 and composer-2)
-   Python
-   NodeJS (node and npm)
-   Graphics tools:
    -   gmagick
    -   png
    -   webp
    -   jpeg
    -   gif
    -   graphviz
-   Video tools
    -   ffmpeg/ffprobe
-   Audio tools
    -   id3
-   SQLite

**Dev containers extends with:**

-   xhprof (with tideways module on /.xdebug)
-   xdebug
-   mysql-client
-   pg-client

## Customizing

### Custom bootstrap scripts

Put `.sh` file in `/docker-entrypoint.d/`

**Example:**

```bash
# /docker-entrypoint.d/10-hello.sh

echo "Hello"

# Pulling codebase
```

### Environment configurations and variables

`PROJECT_ROOT` The project root directory (defaults to `/var/www`)

`PROJECT_PUBLIC` public directory relative to `PROJECT_ROOT` (defaults to `html`)

`COMPOSER_HOME` Sets composer's home (defaults to `<PROJECT_ROOT>/<PROJECT_PUBLIC>`)

`APACHE_UID` - Force set apache runtime _UID_ (by defaults it is empty and uses guest _UID_)

`APACHE_GUID` - Force set apache runtime _GUID_ (by defaults it is empty and uses guest _GUID_)

`TZ` - Set time zone (defaults to `UTC`)

`SERVER_ADMIN` - Set apache's server admin info (defaults to `webmaster@localhost`)

`REMOTE_IP_TRUSTED_PROXY` - Sets apache remote IP trusted list
(defaults to `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16 127.0.0.0/8`)

(dev) `SMTPSERVER` - Set hostname of smtp server (defaults to `mailhog`)

## Examples:

### Simple dev LAMP stack

```yaml
# docker-compose.yml
version: "2"

services:
    www:
        image: dimitrovadrian/webruntime:ubuntu-18.04-dev
        depends_on:
            - "db"
        volumes:
            - "./:/app:cached"
        environment:
            PROJECT_ROOT: "/app"
            PROJECT_PUBLIC: "public"
            MYSQL_ROOT_PASSWORD: "1234"
            MYSQL_HOST: "db"
            APACHE_UID: "1001"
        ports:
            - 80:80
        extra_hosts:
            - "host.docker.internal:host-gateway"
    db:
        image: mysql:5.7
        ports:
            - 3306:3306
        environment:
            MYSQL_ROOT_PASSWORD: "1234"
            MYSQL_DATABASE: "myproject"
    phpmyadmin:
        image: phpmyadmin/phpmyadmin
        ports:
            - 8080:8080
        environment:
            - PMA_HOST=db
            - PMA_USER=root
            - PMA_PASSWORD=1234
    mailhog:
        image: mailhog/mailhog
        ports:
            - 8025:8025
```
