#!/bin/sh

if [ "$(id -u)" != "0" ]; then
    echo "Cannot run as non-root user."
    echo "Use APACHE_UID/APACHE_GUID environment variables for that."
    exit 1
fi

if [ -f "/etc/apache2/envvars" ]; then
    . /etc/apache2/envvars
elif [ -f "/etc/conf.d/apache2" ]; then
    . /etc/conf.d/apache2
fi

if [ -z "$HTTPD" ]; then
    if [ -n "$(command -v httpd)" ]; then
        export HTTPD="httpd"
    else
        export HTTPD="apache2"
    fi
fi

if [ -z "$APACHE_RUN_USER" ]; then
    export APACHE_RUN_USER="apache"
fi

if [ -z "$APACHE_RUN_GROUP" ]; then
    export APACHE_RUN_GROUP="apache"
fi

if [ -n "$APACHE_UID" ]; then
    echo "Set $APACHE_RUN_USER's UID to $APACHE_UID"
    sed -i -r "s/$APACHE_RUN_USER:(\w+):([0-9]+):/$APACHE_RUN_USER:\1:$APACHE_UID:/" /etc/passwd
fi

if [ -n "$APACHE_GUID" ]; then
    echo "Set $APACHE_RUN_GROUP's GUID to $APACHE_GUID"
    sed -i -r "s/$APACHE_RUN_USER:(\w+):([0-9]+):([0-9]+):/$APACHE_RUN_USER:\1:\2:$APACHE_GUID:/" /etc/passwd
    sed -i -r "s/$APACHE_RUN_GROUP:(\w+):([0-9]+):/$APACHE_RUN_GROUP:\1:$APACHE_GUID:/" /etc/group
fi

if [ "/var/www"  != "$PROJECT_ROOT" ]; then
    echo "Fixing $APACHE_RUN_USER's home path"
    sed -i "s@/var/www@$PROJECT_ROOT@" /etc/passwd
fi

if [ -n "$APACHE_UID" ] || [ -n "$APACHE_GUID" ]; then
    echo "Fixing permissions"
    for apachedir in "/var/cache/apache2" "/run/lock/apache2"; do
        if [ -d "$apachedir" ]; then
            chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$apachedir"
        fi
    done
fi

if [ -n "$(cat /etc/hosts | grep 'host.docker.internal')" ]; then
    export REMOTE_IP_TRUSTED_PROXY="$REMOTE_IP_TRUSTED_PROXY host.docker.internal"
    echo "Add host.docker.internal to REMOTE_IP_TRUSTED_PROXY"
elif [ -n "$(command -v netstat)" ]; then
    gw=$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')
    if [ -n "$gw" ]; then
        export REMOTE_IP_TRUSTED_PROXY="$REMOTE_IP_TRUSTED_PROXY $gw"
        echo "add $gw to REMOTE_IP_TRUSTED_PROXY"
    fi
fi

if [ -z "$COMPOSER_HOME" ]; then
    export COMPOSER_HOME="${PROJECT_ROOT}/${PROJECT_PUBLIC}"
    echo "Set COMPOSER_HOME to $COMPOSER_HOME"
fi

if [ -n "$APACHE_PID_FILE" ] && [ -f "$APACHE_PID_FILE" ]; then
    rm -f "$APACHE_PID_FILE"
elif [ -n "$PIDFILE" ] && [ -f "$PIDFILE" ]; then
    rm -f "$PIDFILE"
fi

if [ -d "/docker-entrypoint.d" ]; then
    echo "Executing scripts from /docker-entrypoint.d"
    for file in $(find /docker-entrypoint.d -type f -name "*.sh" | sort); do
        echo "Execute $file"
        sh "$file"
        if [ $? -ne 0 ]; then
            exit 1
        fi
    done
fi

if [ ! -d "$PROJECT_ROOT/$PROJECT_PUBLIC" ]; then
    echo "DocumentRoot: $PROJECT_ROOT/$PROJECT_PUBLIC does not exists."
    exit 1
fi

echo "Starting $HTTPD with DocumentRoot: $PROJECT_ROOT/$PROJECT_PUBLIC"
exec "$HTTPD" -DFOREGROUND
