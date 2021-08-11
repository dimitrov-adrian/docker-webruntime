# 1. Install global /node_modules
# 2. Install PhantomJS as /usr/bin/phantomjs
# 3. Install Casperjs as /usr/bin/casperjs and module in /node_modules
# 4. Install Puppeteer
#   - On ubuntu puppeteer
#   - On alpine puppeteer-core
#   - On all link chrome browser into /usr/bin/chrome

if [ ! -d "/usr/local/lib/node_modules" ]; then
    mkdir -p "/usr/local/lib/node_modules"
fi

if [ ! -d "/node_modules" ]; then
    ln -s /usr/local/lib/node_modules /node_modules
fi

# PhantomJS
if [ -z "$(command -v phantomjs)" ]; then
    curl -L -o /tmp/phantomjs.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
        && tar xf /tmp/phantomjs.tar.bz2 -C /tmp \
        && cp -f /tmp/phantomjs*/bin/* /usr/bin
fi

# CasperJS
if [ -z "$(command -v casperjs)" ]; then
    PREFIX=/usr/local npm install -g casperjs
    ln -s /node_modules/casperjs/bin/casperjs /usr/bin
fi

# Puppeteer
if [ -z "$(command -v chrome)" ]; then
    if [ -n "$(command -v apt)" ]; then
        apt-get -y --no-install-recommends install libxrandr2 libatk1.0-0 libatk-bridge2.0-0 libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxcursor1 libxdamage1 libcups2 libdrm2 libgbm1 libgtk-3-0
        rm -rf /var/lib/apt/lists/*
        usermod -aG audio,video www-data
        PREFIX=/usr/local npm i -g puppeteer
        ln -s   /node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome \
                /node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome-wrapper \
                /node_modules/puppeteer/.local-chromium/linux-*/chrome-linux/chrome_sandbox \
                /usr/bin
    elif [ -n "$(command -v apk)" ]; then
        apk add --no-cache chromium ttf-freefont
        ln -s /usr/bin/chromium-browser /usr/bin/chrome
        if [ -d "/docker-entrypoint.d" ]; then
            mkdir "/docker-entrypoint.d"
        fi
        echo "export PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser"" > /docker-entrypoint.d/puppeteer.sh
        sh /docker-entrypoint.d/puppeteer.sh
        PREFIX=/usr/local npm i -g puppeteer-core
    fi
fi
