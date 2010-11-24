class SecondaryManifest < ShadowPuppet::Manifest
  recipe :foo

  def foo
    user = ENV['SUDO_USER']

    package "koseki-mocksmtpd",
      :provider => :gem

    file "/var/www/mocksmtpd",
      :ensure => :directory,
      :owner => "deploy",
      :group => "www-data",
      :before => exec("screen_mocksmtpd")
    file "/var/www/mocksmtpd/log",
      :ensure => :directory,
      :owner => "deploy",
      :group => "www-data",
      :before => exec("screen_mocksmtpd")
    file "/var/www/mocksmtpd/inbox",
      :ensure => :directory,
      :owner => "deploy",
      :group => "www-data",
      :before => exec("screen_mocksmtpd")

    mocksmtpd_conf = <<-VIMRC
ServerName: mocksmtpd
Port: 2525
RequestTimeout: 120
LineLengthLimit: 1024
LogLevel: INFO

LogFile: ./log/mocksmtpd.log
PidFile: ./log/mocksmtpd.pid
InboxDir: ./inbox
Umask: 2
VIMRC

    file "/var/www/mocksmtpd/mocksmtpd.conf",
      :ensure => :present,
      :content => mocksmtpd_conf,
      :before => exec("screen_mocksmtpd")

    exec "screen_mocksmtpd",
      :unless => "ps aux | grep -v grep | grep 'SCREEN -d -m -S mocksmtpd'",
      :command => "sudo -u deploy screen -d -m -S mocksmtpd",
      :cwd => "/var/www/mocksmtpd",
      :before => exec("screen_mocksmtpd_run")

    exec "screen_mocksmtpd_run",
      :command => "sudo -u deploy screen -S mocksmtpd -p 0 -X exec mocksmtpd",
      :cwd => "/var/www/mocksmtpd"

=begin
    # TODO: finish this next time I rebuild the dev server
    apache_config = <<-APACHE_CONFIG
<VirtualHost *:80>
  ServerName emails.campusforchrist.org

  Redirect 301 / https://emails.campusforchrist.org
</VirtualHost>



<VirtualHost 184.106.199.112:443>

  ServerName emails.campusforchrist.org

  DocumentRoot /var/www/mocksmtpd/inbox
  RailsEnv production
  RailsAutoDetect On

  RailsSpawnMethod smart-lv2

  <Directory /var/www/mocksmtpd/inbox>
    Options FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all

    # Far future expires date
    <FilesMatch "\.(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$">
      ExpiresActive On
      ExpiresDefault "access plus 1 year"
    </FilesMatch>
  </Directory>

  BrowserMatch ".*MSIE.*" \
     nokeepalive ssl-unclean-shutdown \
     downgrade-1.0 force-response-1.0

  # Deflate
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css server/x-javascript
  BrowserMatch ^Mozilla/4 gzip-only-text/html
  BrowserMatch ^Mozilla/4\.0[678] no-gzip
  BrowserMatch \bMSIE !no-gzip !gzip-only-text/html


  # SSL
  SSLEngine on
  SSLProtocol +all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:+SHA1:+MD5:+HIGH:+MEDIUM
  SSLCertificateFile /etc/apache2/certs/campusforchrist.org.cert
  SSLCertificateKeyFile /etc/apache2/certs/campusforchrist.org.key

</VirtualHost>
APACHE_CONFIG

    file "/etc/apache2/site-available/emails.campusforchrist.org"
      :ensure => :present,
      :content => apache_conf,
      :before => exec("restart_apache")
=end
  end
end
