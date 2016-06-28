get-drupal:
   file.managed:
     - name: '/usr/local/src/drupal-7.15.tar.gz'
     - source: http://ftp.drupal.org/files/projects/drupal-7.15.tar.gz
     - source_hash: md5=f42c9baccd74e1d035d61ff537ae21b4
   cmd.run:
     - cwd: /usr/local/src
     - name: tar zxf /usr/local/src/drupal-7.15.tar.gz -C /usr/local/nginx/html
     - require:
       - file: get-drupal
conf-drupal:
   cmd.run:
      - name: mv /usr/local/nginx/html/drupal-7.15 /usr/local/nginx/html/drupal
              && cp /usr/local/nginx/html/drupal/sites/default/default.settings.php /usr/local/nginx/html/drupal/sites/default/settings.php
              && chmod a+w /usr/local/nginx/html/drupal/sites/default/settings.php
              && chmod a+w /usr/local/nginx/html/drupal/sites/default
create-drupal-user:
   file:
      - managed
      - template: jinja
      - name: /sbin/createdb
      - source: salt://createdb.jinja
      - user: root
      - group: root
      - mode: 0755
   cmd.run:
      - name: createdb drupal drupal drupal
