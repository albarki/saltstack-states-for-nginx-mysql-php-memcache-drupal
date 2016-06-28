depends-pkgs:
  cmd.run:
    - name: yum install -y gcc gcc-c++ make zlib-devel pcre-devel openssl-devel libxml2-devel libpng-devel
get-php-5.4-sources:
   file.managed:
     - name: '/usr/local/src/php-5.4.34.tar.gz'
     - source: http://au2.php.net/get/php-5.4.34.tar.gz/from/this/mirror
     - source_hash: md5=718ce85dc1bca0c925a9013638be4ae9
   cmd.run:
     - cwd: /usr/local/src
     - name: tar zxf /usr/local/src/php-5.4.34.tar.gz -C /usr/local/src
compile-php-5.4:
    cmd.run:
      - cwd: /usr/local/src/php-5.4.34
      - user: root
      - names:
        - ./configure --enable-fpm --with-mysql --prefix=/usr/local/php-fpm --with-gd --enable-mbstring --with-pdo-mysql
          &&make
          &&make install
      - watch:
        - cmd: get-php-5.4-sources 
        - cmd: depends-pkgs
configure-php5.4:
    cmd.run:
      - cwd: /usr/local/src/php-5.4.34
      - user: root
      - names:
        - cp php.ini-development /usr/local/php-fpm/lib/php.ini
          && cp  /usr/local/src/php-5.4.34/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
          && chmod u+x /etc/init.d/php-fpm
          && cp  /usr/local/php-fpm/etc/php-fpm.conf.default /usr/local/php-fpm/etc/php-fpm.conf
          && cp /usr/local/src/php-5.4.34/sapi/fpm/php-fpm /usr/local/php-fpm/bin
      - watch:
        - cmd: compile-php-5.4
php-fpm-config-block:
  file.blockreplace:
    - name: /usr/local/php-fpm/etc/php-fpm.conf
    - marker_start: "user = nobody"
    - marker_end: "group = nobody"
    - content: |
          user = nginx
          group = nginx
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True
php-fpm-config-block-comment1:
   file.comment:
      - name: /usr/local/php-fpm/etc/php-fpm.conf
      - regex: "^group = nobody$"
      - char: ;hema
php-fpm-config-block-comment2:
   file.comment:
      - name: /usr/local/php-fpm/etc/php-fpm.conf
      - regex: "^user = nobody$"
      - char: ;hema
      - require:
         - file: php-fpm-config-block-comment1
php-ini-config-block1:
  file.replace:
    - name: /usr/local/php-fpm/lib/php.ini
    - pattern: "^;cgi.fix_pathinfo=1$"
    - repl: "cgi.fix_pathinfo=1"
    - append_if_not_found: True
    - show_changes: True
php-ini-config-block2:
  file.replace:
    - name: /usr/local/php-fpm/lib/php.ini
    - pattern: ^;include_path = ".:/php/includes"
    - repl: |
         include_path = ".:/usr/local/php-fpm/lib/php"
         include_path = ".:/php/includes"
    - append_if_not_found: True
    - show_changes: True
    - require: 
       - file: php-ini-config-block1
php-fpm-config-block2:
  file.replace:
    - name: /usr/local/php-fpm/etc/php-fpm.conf
    - pattern: ^pm = dynamic$
    - repl: pm = ondemand
    - append_if_not_found: True
php-fpm:
   service:
      - running
      - enable: True
      - reload: True
      - watch:
        - cmd: configure-php5.4
        - file: php-fpm-config-block
        - file: php-fpm-config-block-comment2
        - file: php-ini-config-block2
        - file: php-fpm-config-block
