memcached:
  cmd.run:
    - name: yum install -y memcached
  service:
    - running
    - enable: True
    - reload: True
    - require: 
      - cmd: memcached
depends-pkgs:
  cmd.run:
    - name: yum install -y autoconf
    - unless: rpm -qa | grep -i autoconf
activate-memcachedPlugin:
  cmd.run:
    - name: /usr/local/php-fpm/bin/pecl install memcache
  service:
    - name: php-fpm
    - running
    - enable: True
    - watch:
      - cmd: activate-memcachedPlugin
      - cmd: php-ini-conf
php-ini-conf:
   cmd.run:
     - name: echo extension=memcache.so >> /usr/local/php-fpm/lib/php.ini
     - unless: grep -i extension="apc.so" /usr/local/php-fpm/lib/php.ini
     - require:
       - cmd: activate-memcachedPlugin

