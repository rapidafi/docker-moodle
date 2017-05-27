# Dockerfile for moodle instance. More dockerish version of https://github.com/sergiogomez/docker-moodle
# Forked from Jon Auer's docker version. https://github.com/jda/docker-moodle
# Forked from Jonathan Hardison's docker version. https://github.com/jmhardison/docker-moodle
FROM ubuntu:16.04
LABEL maintainer Rapida <rapida@rapida.fi>
#Previous Maintainer Jonathan Hardison <jmh@jonathanhardison.com>
#Original Maintainer Jon Auer <jda@coldshore.com>

# Let the container know that there is no tty (and other envs; sh/could be passed)
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Helsinki \
    MOODLE_URL=${MOODLE_URL} \
    CERT_EMAIL=${CERT_EMAIL} \
    CERT_DOMAIN=${CERT_DOMAIN}

# Add repositories
RUN apt-key adv --keyserver "hkp://keyserver.ubuntu.com:80" --recv 'E5267A6C' && \
    apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    add-apt-repository ppa:certbot/certbot

# Install & Cleanup
RUN apt-get update && \
  apt-get -y install \
    postfix unzip wget vim git \
    curl libcurl3 libcurl3-dev \
    python-setuptools \
    apache2 supervisor python-certbot-apache \
    mysql-client pwgen \
    php php-gd libapache2-mod-php php-curl php-xml php-xmlrpc \
    php-intl php-mysql php-zip php-mbstring php-soap php-mcrypt && \
  apt-get clean autoclean && \
  apt-get autoremove -y

# Enable SSL, moodle requires it (no site though, certbot handles)
RUN a2enmod ssl # && a2ensite default-ssl # if using proxy, don't need actually secure connection

# Install/Get Moodle (nb! version)
ADD https://download.moodle.org/download.php/direct/stable32/moodle-latest-32.tgz /tmp/moodle-latest.tgz
RUN rm -rf /var/www/html/* ; \
    cd /tmp && \
    tar zxvf moodle-latest.tgz && \
    mv moodle/* /var/www/html/

COPY moodle-config.php /var/www/html/config.php

# Add theme
ADD https://github.com/rapidafi/moodle-theme_ssbl/archive/master.zip /tmp/moodle-theme_ssbl.zip
RUN mkdir -p /var/www/html/theme && \
    cd /var/www/html/theme && \
    mv /tmp/moodle-theme_ssbl.zip . && \
    unzip moodle-theme_ssbl.zip && \
    mv moodle-theme_ssbl-master photo

RUN chown -R www-data:www-data /var/www/html

# Get Finnish Language Pack (todo versioning! now we know version to be 3.2)
ADD https://download.moodle.org/download.php/direct/langpack/3.2/fi.zip /tmp/fi.zip
RUN mkdir -p /var/moodledata/lang && \
    cd /var/moodledata/lang && \
    mv /tmp/fi.zip . && \
    unzip fi.zip

RUN chown -R www-data:www-data /var/moodledata && \
    chmod -R 777 /var/moodledata

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/var/moodledata"]
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

