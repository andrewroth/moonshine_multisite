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
  end
end
