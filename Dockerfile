
##
# Drupal/SSH with Nginx, PHP5 and MySQL
##
FROM ubuntu
MAINTAINER http://www.github.com/b7alt/ by b7alt

#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor openssh-server nginx php7-fpm php7-sqlite php7-gd drush php-apc git emacs
RUN update-rc.d nginx disable
RUN update-rc.d php7-fpm disable
RUN update-rc.d supervisor disable
RUN update-rc.d ssh disable

EXPOSE 22 80

RUN mkdir -p /var/run/sshd /srv/drupal/www /srv/drupal/config /srv/data /srv/logs /tmp

ADD support/docker/site.conf /srv/drupal/config/site.conf
ADD support/docker/nginx.conf /nginx.conf
ADD support/docker/php-fpm.conf /php-fpm.conf
ADD support/docker/supervisord.conf /supervisord.conf
ADD support/docker/settings.php.append /settings.php.append

RUN cd /tmp && drush dl drupal && mv /tmp/drupal*/* /srv/drupal/www/ && rm -rf /tmp/*
RUN chmod a+w /srv/drupal/www/sites/default && mkdir /srv/drupal/www/sites/default/files
RUN chown -R www-data:www-data /srv/drupal/www/
RUN cp /srv/drupal/www/sites/default/default.settings.php /srv/drupal/www/sites/default/settings.php
RUN chmod a+w /srv/drupal/www/sites/default/settings.php
RUN chown www-data:www-data /srv/data


#RUN chmod a+w /srv/drupal/www/sites/default/files
# RUN cd /srv/drupal/www/ && drush -y site-install standard --account-name=admin --account-pass=test --db-url=sqlite:sites/default/files/.ht.sqlite
RUN cd /srv/drupal/www/ && drush -y site-install static_api --account-name=admin --account-pass=test --db-url=mysql://drupal8user:drupal8password@staticapi.db:3306/drupal8

RUN cat /settings.php.append >> /srv/drupal/www/sites/default/settings.php

RUN ls -al /srv/drupal/www/sites/default/files
RUN chmod a-w /srv/drupal/www/sites/default/settings.php

RUN chown -R www-data:www-data /srv/drupal/www/

RUN echo "root:root" | chpasswd
RUN sed --in-place=.bak 's/without-password/yes/' /etc/ssh/sshd_config

ENTRYPOINT [ "/usr/bin/supervisord", "-n", "-c", "/supervisord.conf", "-e", "trace" ]
