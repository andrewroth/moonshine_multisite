module Moonshine::Manifest::Rails::God

  # Installs <tt>god monitoring framework</tt> from gem and installs a config
  # to <tt>/etc/god/god.rb</tt>.  Adds a config file in 
  # <tt>/etc/god/apps/<application>.yml</tt> if :delayed_job is set to true in
  # moonshine.yml
  def god
    gem 'god'
    file '/etc/god', :ensure => :directory
    file '/etc/god/apps', :ensure => :directory
    file '/etc/god/god.rb',
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'god.rb.erb'))
    if configuration[:delayed_job]
      file "/etc/god/apps/#{configuration[:server_name]}.yml",
        :ensure => :present,
        :content => template(File.join(File.dirname(__FILE__), 'templates', 'god_app.yml.erb')),
        :before => [ exec("god_start"), exec("god_stop") ]
    end
    god_restart
  end

  def god_start
    exec "god_start", 
      :command => "sudo god -c /etc/god/god.rb start",
      :require => package("god")
  end

  def god_stop
    exec "god_stop", :command => "sudo god quit",
      :onlyif => "ps aux | grep '/usr/bin/ruby /usr/bin/[g]od'; test \"$?\" -eq 0",
      :before => exec("god_start")
  end

  def god_restart
    god_stop
    god_start
  end
end
