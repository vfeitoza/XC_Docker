# Usa uma imagem base leve (ex: Debian ou Ubuntu)
FROM ubuntu:24.04

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# 1. Atualiza e instala dependências básicas e o supervisor
RUN apt-get update && apt-get install -y \
    curl \
    software-properties-common \
    ca-certificates \
    python3 \
    python3-pip \
    supervisor \
    unzip wget curl nano sudo unzip htop cron iputils-ping \
    && rm -rf /var/lib/apt/lists/*


# 2. Instala o Supercronic
# Baixamos direto do GitHub Releases
RUN SUPERCRONIC_URL=$(curl -s https://api.github.com/repos/aptible/supercronic/releases/latest | grep 'browser_download_url' | grep 'linux-amd64' | cut -d '"' -f 4) \
    && wget -q "$SUPERCRONIC_URL" -O /usr/local/bin/supercronic \
    && chmod +x /usr/local/bin/supercronic

# 3. Configurando repositório para o MAriaDB 11.4 e MaxMind
RUN curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --mariadb-server-version="mariadb-11.4"
RUN add-apt-repository -y ppa:maxmind/ppa 
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    libmaxminddb0 \
    libmaxminddb-dev \
    mmdb-bin 

# 4. Instala dependencias para o XC_VM
RUN apt-get install -y \
    cpufrequtils \
    iproute2 \
    net-tools \
    dirmngr \
    gpg-agent \
    libcurl4 \
    libgeoip-dev \
    libxslt1-dev \
    libonig-dev \
    e2fsprogs \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



# 5. Copia os arquivos de configuração e extras para o sistema

# Criando dados do mysql e logs 
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld \
    && mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld  \
    && mkdir -p /var/log/supervisor

# Adicionando usuario do sistema
RUN adduser --system --shell /bin/false --group --disabled-login xc_vm

# Copia o wrapper do systemctl
COPY scripts/systemctl /usr/local/bin/systemctl
RUN chmod +x /usr/local/bin/systemctl

# Copia as configurações do supervisor
COPY config/supervisor/xc_vm.conf /etc/supervisor/conf.d/xc_vm.conf
COPY config/supervisor/supercronic.conf /etc/supervisor/conf.d/supercronic.conf
COPY config/supervisor/mariadb.conf /etc/supervisor/conf.d/mariadb.conf
COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Copia o crontab
COPY config/crontab /etc/crontab

# Copia scripts extras
RUN mkdir /scripts
COPY scripts/init-xc_vm.sh /scripts/init-xc_vm.sh
COPY scripts/status-server.sh /scripts/status-server.sh
COPY scripts/xc_install /scripts/xc_install
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /scripts/init-xc_vm.sh
RUN chmod +x /scripts/status-server.sh
RUN chmod +x /scripts/xc_install
RUN chmod +x /usr/local/bin/docker-entrypoint.sh


# 6. Adicionando usuario do sistema
RUN adduser --system --shell /bin/false --group --disabled-login xc_vm


# 7. Setando fuso horário
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# 8. Setando lsb_release manualmente (preservar script de instalação)
RUN echo '#!/bin/bash\nif [ "$1" = "-a" ] || [ "$1" = "--all" ]; then\n  echo "Distributor ID: Ubuntu"\n  echo "Description:    Ubuntu 24.04 LTS"\n  echo "Release:        24.04"\n  echo "Codename:       noble"\nelif [ "$1" = "-d" ] || [ "$1" = "--description" ]; then\n  echo "Description:    Ubuntu 24.04 LTS"\nelif [ "$1" = "-r" ] || [ "$1" = "-sr" ] || [ "$1" = "--release" ]; then\n  echo "24.04"\nelif [ "$1" = "-c" ] || [ "$1" = "--codename" ]; then\n  echo "Codename:       noble"\nelif [ "$1" = "-i" ] || [ "$1" = "--id" ]; then\n  echo "Distributor ID: Ubuntu"\nelif [ "$1" = "-s" ] || [ "$1" = "--short" ]; then\n  if [ "$2" = "-r" ]; then\n    echo "24.04"\n  fi\nfi' > /usr/bin/lsb_release && chmod +x /usr/bin/lsb_release


# 9. Portas a serem exportadas
EXPOSE 3306 8080 8443 8880


# 10. Configuração de Entrypoint e CMD
# O ENTRYPOINT roda primeiro: inicializa o DB se necessário, seta senha, e sai.
# O CMD roda depois: inicia o Supervisor, que cuida do mysqld "definitivo".
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
