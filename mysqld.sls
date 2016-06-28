install-pkgs:
  cmd.run:
    - name: yum -y install mysql mysql-server
    - user: root
    - unless: rpm -qa | grep -i mysql-server
  service:
    - running
    - name: mysqld
    - enable: true
    - watch:
      - cmd: install-pkgs 
