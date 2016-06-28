# saltstack-states-for-nginx-mysql-php-memcache-drupal
Automate installing LEMP stack using saltstack

1. init.sls
	install nginx and start the service 
2. mysqld.sls
	install mysql server and start the service
3. phpcompile.sls
	compile php and install it
4. apccache.sls
	apc cache module for php
5. memcache.sls
	install memcached server and memcache php plugin
6. drupal.sls
	install drupal files and create drupal db with user/password drupal/drupal

That is it...
