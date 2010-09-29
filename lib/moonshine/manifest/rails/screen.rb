module Moonshine::Manifest::Rails::Monit

  # Installs <tt>screen utility</tt>
  # Adds a ruby script in 
  # <tt>/etc/screen.d/ if delayed_job is set to true
  # that can be run to start/restart the current rake jobs:work
  # rake task, if delayed_job flag is set.
  def screen
    package "screen", :ensure => :installed

    file '/etc/screen.d', :ensure => :directory
    if configuration[:delayed_job]
      file "/etc/screen.d/#{configuration[:application]}.rb",
        :ensure => :present,
        :content => template(File.join(File.dirname(__FILE__), 'templates', 'screen.rb.erb')),
        :before => exec("screen_dj_restart"),
        :require => package("screen")
    else
      file "/etc/screen.d/#{configuration[:application]}.rb",
        :ensure => :absent,
        :before => exec("screen_dj_stop"),
        :require => package("screen_dj_stop")
    end
    screen_dj_restart
  end

  def screen_dj_restart
    exec "screen_dj_restart", 
      :command => "ruby /etc/screen.d/#{configuration[:application]}.rb",
      :require => package("screen")
  end

  def screen_dj_stop
    exec "screen_dj_stop", 
      :command => "screen -S #{configuration[:application]} -X kill",
      :require => package("screen")
  end
end
