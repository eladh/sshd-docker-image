FROM sickp/alpine-sshd:latest


# System
RUN apk update && apk add --no-cache --virtual .build-deps \
    ca-certificates \
    apache2-utils \
    curl \
    tar \
    bash \
    openssl \
    python \
    git

RUN apk update \
    && apk add --no-cache \
        sudo nano screen bash rsync rdiff-backup \
    && rm -rf /tmp/* /var/tmp/*

# add openssh and clean
RUN apk add --no-cache openssh \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd

#add default ssh key
ADD ssh/id_rsa.pub /root/.ssh/
ADD ssh/id_rsa /root/.ssh/

WORKDIR /

# Install docker client
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 19.03.1
#ENV DOCKER_API_VERSION 1.27
RUN curl -fsSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" \
  | tar -xzC /usr/local/bin --strip=1 docker/docker

# add entrypoint script
ADD ./docker-entrypoint.sh /usr/local/bin

#expose SSH Service
EXPOSE 22


ENTRYPOINT [ "bash", "docker-entrypoint.sh" ]
