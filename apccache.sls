depends-pkgs:
  cmd.run:
    - name: yum install -y autoconf
    - unless: rpm -qa | grep -i autoconf
activate-apc:
  cmd.run:
    - name: /usr/local/php-fpm/bin/pecl install apc 
  service:
    - name: php-fpm
    - running
    - enable: True
    - reload: True
    - require:
      - cmd: activate-apc
      - cmd: php-ini-conf
php-ini-conf:
   cmd.run:
     - name: echo extension="apc.so" >> /usr/local/php-fpm/lib/php.ini
     - unless: grep -i extension="apc.so" /usr/local/php-fpm/lib/php.ini
     - require:
       - cmd: activate-apc
