FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    make \
    g++ \
    python3 && \
    rm -rf /var/lib/apt/lists/*

# Node.js 18: LTS(Long-term support) version
# “Download the resource quietly, follow redirects, and only display errors if something goes wrong.
# -f: fail (do not show HTTP server (web page 404...) error)
#  s: slient mode (hide progress mode)
#  S: show errors
#  L: follow redirects automatically
# bash -: bash read and execute from stdin
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# = cd /app
# download uptime-kuma
WORKDIR /app
RUN git clone https://github.com/louislam/uptime-kuma.git .

# npm: Node.js Package Manager (= apt)
# run setup script in package.json
RUN npm run setup && \
    npm cache clean --force

EXPOSE 3001

# = run "docker node server/server.js" when server starts up
CMD ["node", "server/server.js"]