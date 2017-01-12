#!/usr/bin/env bash
cd /var/www/html/htdocs && /var/www/html/vendor/bin/drush -y site-install static_api --account-name=admin --account-pass=test --db-url=mysql://drupal8user:drupal8password@db:3306/drupal8
curl http://localhost/cities.json
