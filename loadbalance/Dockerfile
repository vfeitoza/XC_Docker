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
    openssh-server \
    unzip wget curl nano sudo unzip htop cron iputils-ping \
    && rm -rf /var/lib/apt/lists/*


# 2. Instala o Supercronic
# Baixamos direto do GitHub Releases
RUN SUPERCRONIC_URL=$(curl -s https://api.github.com/repos/aptible/supercronic/releases/latest | grep 'browser_download_url' | grep 'linux-amd64' | cut -d '"' -f 4) \
    && wget -q "$SUPERCRONIC_URL" -O /usr/local/bin/supercronic \
    && chmod +x /usr/local/bin/supercronic
    
# 3. Instala dependencias para o XC_VM funcionar como Load Balance
RUN add-apt-repository -y ppa:maxmind/ppa 
RUN apt-get update && apt-get install -y \
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
    libmaxminddb0 \
    libmaxminddb-dev \
    mmdb-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# 4. Cria um diretório para logs (opcional, pois vamos redirecionar para stdout) e permissões do MariaDB
RUN mkdir -p /var/log/supervisor


# 5. Configura o SSH
# Cria o diretório de rodar o ssh (necessário em alguns containers)
RUN mkdir /var/run/sshd
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# (Opcional) Permite login do root via senha.
# CUIDADO: Em produção, use chaves SSH em vez de senha.
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Define a senha do usuário 'root' para 'senha123' (Mude isso!)
RUN echo 'root:senha123' | chpasswd


# 6. Copia os arquivos de configuração

# Copia o wrapper do systemctl
COPY scripts/systemctl /usr/local/bin/systemctl
RUN chmod +x /usr/local/bin/systemctl

# Copia as configurações do supervisor
COPY config/supervisor/xc_vm.conf /etc/supervisor/conf.d/xc_vm.conf
COPY config/supervisor/supercronic.conf /etc/supervisor/conf.d/supercronic.conf
COPY config/supervisor/ssh.conf /etc/supervisor/conf.d/ssh.conf
COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Copia o crontab
COPY config/crontab /etc/crontab

# Copia scripts extras
RUN mkdir /scripts
COPY scripts/init-xc_vm.sh /scripts/init-xc_vm.sh
COPY scripts/status-server.sh /scripts/status-server.sh
RUN chmod +x /scripts/init-xc_vm.sh
RUN chmod +x /scripts/status-server.sh


# 7. Adicionando usuario do sistema
RUN adduser --system --shell /bin/false --group --disabled-login xc_vm


# 8. Setando fuso horário
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# 9. Setando lsb_release manualmente (preservar script de instalação)
RUN echo '#!/bin/bash\nif [ "$1" = "-a" ] || [ "$1" = "--all" ]; then\n  echo "Distributor ID: Ubuntu"\n  echo "Description:    Ubuntu 24.04 LTS"\n  echo "Release:        24.04"\n  echo "Codename:       noble"\nelif [ "$1" = "-d" ] || [ "$1" = "--description" ]; then\n  echo "Description:    Ubuntu 24.04 LTS"\nelif [ "$1" = "-r" ] || [ "$1" = "-sr" ] || [ "$1" = "--release" ]; then\n  echo "24.04"\nelif [ "$1" = "-c" ] || [ "$1" = "--codename" ]; then\n  echo "Codename:       noble"\nelif [ "$1" = "-i" ] || [ "$1" = "--id" ]; then\n  echo "Distributor ID: Ubuntu"\nelif [ "$1" = "-s" ] || [ "$1" = "--short" ]; then\n  if [ "$2" = "-r" ]; then\n    echo "24.04"\n  fi\nfi' > /usr/bin/lsb_release && chmod +x /usr/bin/lsb_release


# 10. Portas a serem exportadas
EXPOSE 80 2222 8880


# 11. Configuração do CMD
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
