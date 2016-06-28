depends-pkgs:
  cmd.run:
    - name: yum install -y gcc gcc-c++ make zlib-devel pcre-devel openssl-devel
get-nginx-requirements:
   file.managed:
     - name: '/usr/local/src/nginx-1.6.2.tar.gz'
     - source: http://nginx.org/download/nginx-1.6.2.tar.gz
     - source_hash: md5=d1b55031ae6e4bce37f8776b94d8b930
   cmd.run:
     - cwd: /usr/local/src
     - name: tar zxf /usr/local/src/nginx-1.6.2.tar.gz -C /usr/local/src
     - require:
       - cmd: depends-pkgs
nginx:
    cmd.run:
      - cwd: /usr/local/src/nginx-1.6.2
      - names:
        - ./configure 
          --user=nginx --group=nginx 
          --prefix=/usr/local/nginx 
          --with-http_ssl_module 
          --with-pcre
          &&make
          &&make install
      - watch:
        - cmd: get-nginx-requirements
        - cmd: depends-pkgs
    file:
      - managed
      - template: jinja
      - name: /etc/init.d/nginx
      - source: salt://nginx/nginx.init.jinja
      - user: root
      - group: root
      - mode: 0755
    service:
      - running
      - enable: True
      - reload: True
      - watch:
        - cmd: nginx
        - user: nginx_user
        - file: /usr/local/nginx/conf/nginx.conf
        - cmd: checkopen-http-port
nginx_user:
     user.present:
       - name: nginx
       - home: /usr/local/nginx/html
       - shell: /sbin/nologin
       - groups: 
         - nginx
       - watch:
         - group: nginx_group
     file.directory:
       - name: /usr/local/nginx/html
       - user: nginx
       - group: nginx
       - mode: 0755
       - watch:
         - group: nginx_group
         - user: nginx_user
nginx_group:
     group.present:
       - name: nginx
delete-nginx.conf:
  file.absent:
     - name: /usr/local/nginx/conf/nginx.conf
     - require:
        - cmd: nginx
/usr/local/nginx/conf/nginx.conf:
  file:
    - managed
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - source: salt://nginx/config.jinja
checkopen-http-port:
  cmd.run:
    - name: iptables -I INPUT 4 -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT && /etc/init.d/iptables save
    - user: root
    - unless: grep -i 80 /etc/sysconfig/iptables
