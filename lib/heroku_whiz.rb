#!/usr/bin/env ruby

# file: heroku_whiz.rb

# created: 8th March 2022
# description: Handy (experimental) Heroku gem for noobs to create a
#              simple Heroku app in a whiz!

# note: If this gem becomes outdated because of a change in the Heroku app
#       setup process, please inform the owner of this project via *Issues*
#       on GitHub (https://github.com/jrobertson/heroku_whiz).


require 'open-uri'
require 'fileutils'
require 'clipboard'


# Resources
#
# * [Deploying Rack-based Apps](https://devcenter.heroku.com/articles/rack#pure-rack-apps)


# Example usage:
#
# hw = HerokuWhiz.new dir: '/home/james/heroku', template: 'rack', appname: 'hello2', debug: true
#
# hw.wipe_clean    # removes the previous local app file directory
# hw.create        # creates the local app file directory
# #hw.local_run    # runs the web app locally
# hw.local_testrun # tests the local web app returns the correct page
# hw.deploy        # creates the new app on Heroku
# hw.app_url       #=> e.g. https://frozen-dusk-65820.herokuapp.com/


class HerokuWhiz

  def initialize(dir: '.', template: 'rack', appname: 'myapp',
        verbose: true, debug: false)

    @dir, @template, @appname, @verbose = dir, template, appname, verbose

    @app_path = File.join(@dir, @appname)


  end

  def app_url()

    app = `heroku config`.lines.first.split[1]
    s = "https://#{app}.herokuapp.com/"

    Clipboard.copy s
    puts 'app URL copied to clipboard.'

    return s

  end

  def create()

    case @template.to_sym
    when :rack
      create_rack()
    else
      return puts 'template not recognised!'
    end

    # build
    `bundle install`
    sleep 1

  end

  def wipe_clean(setup=:local)

    return unless File.exists? @app_path

    # remove the app files
    #
    %w(Gemfile config.ru Gemfile.lock).each do |file|

      puts 'removing file ' + file if @debug
      rm File.join(@app_path, file)
      sleep 0.5

    end

    rm_rf File.join(@app_path, '.git')
    rmdir File.join(@app_path, '.git')
    rmdir @app_path

    return unless setup == :both

    app = `heroku config`.lines.first.split[1]
    `heroku apps:destroy --confirm #{app}`

  end

  def deploy()

    `git init`
    sleep 0.5

    `git add .`
    sleep 0.5

    `git commit -m 'pure rack app'`
    sleep 0.5

    #`heroku create #{@appname}`

    # the above statement was commented out because there's a
    # high probability the appname you have chosen has already been taken
    #  e.g. hello2 => hello2.herokuapp.com

    `heroku create`
    sleep 2

    r = `git push heroku master`

  end

  def local_run()
    `bundle exec rackup -p 9292 config.ru &`
  end

  def local_testrun()

    r = IO.popen( "bundle exec rackup -p 9292 config.ru" )
    puts 'r: ' + r.inspect if @debug
    sleep 2

    s = URI.open('http://127.0.0.1:9292').read
    sleep 1

    Process.kill('QUIT', r.pid)


    puts 'SUCCESS! Ready to deploy' if s == "Hello World!\n"

  end

  private

  def create_rack()

    FileUtils.mkdir_p @app_path
    FileUtils.chdir @app_path

    # write the config.ru file
    #
    config = %q(
run lambda {|env|
  [200, {'Content-Type'=>'text/plain'}, StringIO.new("Hello World!\n")]
})
    File.write File.join(@app_path, 'config.ru'), config

    # write the Gemfile
    #
    gemfile = %q(
source 'https://rubygems.org'
gem 'rack'
gem 'puma'
)
    File.write File.join(@app_path, 'Gemfile'), gemfile
    sleep 0.5

  end

  def rm(file)
    FileUtils.rm file if File.exists? file
  end

  def rm_rf(file)
    FileUtils.rm_rf file if File.exists? file
  end

  def rmdir(file)
    FileUtils.rmdir file if File.exists? file
  end

end

