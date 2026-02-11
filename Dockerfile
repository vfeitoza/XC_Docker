FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    supervisor \
    unzip wget curl nano sudo unzip htop \
    cpufrequtils \
    iproute2 \
    net-tools \
    dirmngr \
    gpg-agent \
    software-properties-common \
    libmaxminddb0 \
    libmaxminddb-dev \
    mmdb-bin \
    libcurl4 \
    libgeoip-dev \
    libxslt1-dev \
    libonig-dev \
    e2fsprogs \
    mariadb-server \
    mariadb-client \
    sysstat \
    alsa-utils \
    v4l-utils \
    mcrypt \
    certbot \
    iptables-persistent \
    libjpeg-dev \
    libpng-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libogg0 \
    libnuma1 \
    xz-utils \
    zip \
    unzip \
    libssh2-1t64 \
    php-ssh2 \
    cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Criando dados do mysql
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld \
    && mkdir -p /var/log/supervisor

# Adicionando usuario do sistema
RUN adduser --system --shell /bin/false --group --disabled-login xc_vm

# Copiando scripts para gerencia do container
COPY ./scripts /scripts
#COPY ./scripts/init-mariadb.sh /scripts/scripts/init-mariadb.sh
#COPY ./scripts/init-xc.sh /scripts/init-xc.sh
#COPY ./scripts/restart-mariadb.sh /scripts/restart-mariadb.sh
#COPY ./scripts/status-server.sh /scripts/status-server.sh
#COPY ./scripts/xc_install /scripts/xc_install

# Copiando arquivo de configuração do supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Tornando executáveis os scripts
RUN chmod +x /scripts/init-mariadb.sh
RUN chmod +x /scripts/init-xc.sh
RUN chmod +x /scripts/restart-mariadb.sh
RUN chmod +x /scripts/status-server.sh
RUN chmod +x /scripts/xc_install

# Setando lsb_release manualmente (preservar script de instalação)
RUN echo '#!/bin/bash\nif [ "$1" = "-a" ] || [ "$1" = "--all" ]; then\n  echo "Distributor ID: Ubuntu"\n  echo "Description:    Ubuntu 24.04 LTS"\n  echo "Release:        24.04"\n  echo "Codename:       noble"\nelif [ "$1" = "-d" ] || [ "$1" = "--description" ]; then\n  echo "Description:    Ubuntu 24.04 LTS"\nelif [ "$1" = "-r" ] || [ "$1" = "-sr" ] || [ "$1" = "--release" ]; then\n  echo "24.04"\nelif [ "$1" = "-c" ] || [ "$1" = "--codename" ]; then\n  echo "Codename:       noble"\nelif [ "$1" = "-i" ] || [ "$1" = "--id" ]; then\n  echo "Distributor ID: Ubuntu"\nelif [ "$1" = "-s" ] || [ "$1" = "--short" ]; then\n  if [ "$2" = "-r" ]; then\n    echo "24.04"\n  fi\nfi' > /usr/bin/lsb_release && chmod +x /usr/bin/lsb_release

EXPOSE 3306 8080 8443 8880

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
