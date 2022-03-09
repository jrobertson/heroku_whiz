#!/usr/bin/env ruby

# file: heroku_whiz.rb

# created: 8th March 2022
# updated: 9th March 2022

# description: Handy (experimental) Heroku gem for noobs to create a
#              simple Heroku app in a whiz!

# Q: Why Heroku?
#
# A: With a quick Twitter search for Free wen hosting, a
#    popular Tweet mentioned Heroku
#
# 10 FREE Hosting/Clouds for Your website:
#
# ➡️ GitHub Pages
# ➡️ Heroku
# ➡️ Amazon Web Services (AWS)
# ➡️ Vercel
# ➡️ Firebase Hosting
# ➡️ Awardspace
# ➡️ Netlify
# ➡️ Google Cloud
# ➡️ Cloudflare
# ➡️ Weebly
#


# note: If this gem becomes outdated because of a change in the Heroku app
#       setup process, please inform the owner of this project via *Issues*
#       on GitHub (https://github.com/jrobertson/heroku_whiz).


require 'open-uri'
require 'fileutils'
require 'clipboard'
require 'launchy'

# Resources
#
# * [Deploying Rack-based Apps](https://devcenter.heroku.com/articles/rack#pure-rack-apps)


# Example usage:
#
# hw = HerokuWhiz.new dir: '/home/james/heroku', template: 'rack',
#                     appname: 'hello2', debug: true
#
# hw.wipe_clean    # removes the previous local app file directory
# hw.create        # creates the local app file directory
# #hw.local_run    # runs the web app locally
# hw.local_testrun # tests the local web app returns the correct page
# hw.deploy        # creates the new app on Heroku
# hw.app_url       #=> e.g. https://frozen-dusk-65820.herokuapp.com/



class WhizBase

  def initialize(app_path, verbose: true, debug: false)

    @app_path, @verbose, debug = app_path, verbose, debug

  end

  def create(add: nil)

    config = %q(
run lambda {|env|
  [200, {'Content-Type'=>'text/plain'}, StringIO.new("Hello World!\n")]
})

    gemfile = %q(
source 'https://rubygems.org'
gem 'rack'
gem 'puma'
)

    # Procfile: see https://devcenter.heroku.com/articles/procfile
    #           for more info
    procfile = 'web: bundle exec rackup config.ru -p $PORT'

    create_basefiles(config, gemfile, procfile)
  end

  # currently only removes a file directory if there are no user created files
  #
  def wipe_clean(setup=:local)

    return unless File.exists? @app_path

    # remove the app files
    #
    %w(Gemfile config.ru Procfile Gemfile.lock).each do |file|

      puts 'removing file ' + file if @debug
      rm File.join(@app_path, file)
      sleep 0.5

    end

    appname = heroku_app()

    if setup == :both then

      Clipboard.copy appname
      puts 'App name ' + appname + ' copied to clipboard'
      `heroku apps:destroy #{appname}`

    end

    rm_rf File.join(@app_path, '.git')
    rmdir File.join(@app_path, '.git')
    rmdir @app_path

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

    puts  'Running *heroku create*' if @verbose
    `heroku create`
    sleep 3

    puts  'Running *git push heroku master*' if @verbose
    r = `git push heroku master`
    sleep 10

  end

  def local_run()

    #`heroku local &`
    # attempted to use heroku local but couldn't automatically kill the
    # process directly

    `bundle exec rackup -p 9292 config.ru &`
  end

  def local_testrun()

    #r = IO.popen("heroku local")
    r = IO.popen("bundle exec rackup -p 9292 config.ru")
    puts 'r: ' + r.inspect if @debug
    sleep 2

    s = URI.open('http://127.0.0.1:9292').read
    sleep 1

    Process.kill('QUIT', r.pid)

    puts 'SUCCESS! Ready to deploy' if s == "Hello World!\n"

  end

  private

  def create_basefiles(config, gemfile, procfile)

    FileUtils.mkdir_p @app_path
    FileUtils.chdir @app_path

    # write the config.ru file
    #
    File.write File.join(@app_path, 'config.ru'), config
    sleep 0.2

    # write the Gemfile
    #
    File.write File.join(@app_path, 'Gemfile'), gemfile
    sleep 0.2

    # write the Procfile (although not essential it will flag a warning when
    # deploying if the file doesn't exist
    #
    File.write File.join(@app_path, 'Procfile'), procfile
    sleep 0.2

  end

  def heroku_app()
    s = `heroku config`
    s.lines.first.split[1] if s
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

class SinatraWhizError < Exception
end

class SinatraWhiz < WhizBase

  def initialize(app_path, verbose: true, debug: false)
    super(app_path, verbose: verbose, debug: debug)
  end

  def create(add: nil)

    if add then

      FileUtils.mkdir_p @app_path
      FileUtils.chdir @app_path

      # copying the files into file directory @app_path
      # ensure the files config.ru, Gemfile, and Procfile exist
      #
      a = Dir.glob(File.join(add,'*'))
      files = a.map {|x| File.basename(x)}

      expected = %w(config.ru Gemfile Procfile)
      found = (files & expected)

      if found.length < 3 then
        raise SinatraWhizError, 'missing ' + (expected - found).join(', ')
      end

      puts 'copying files ' + a.inspect if @debug

      a.each {|x| FileUtils.cp x, @app_path }

    else

      config = %q(
require './hello'
run Sinatra::Application
)
      gemfile = %q(
source 'https://rubygems.org'
gem 'sinatra'
gem 'puma'
)

      procfile = 'web: bundle exec rackup config.ru -p $PORT'
      create_basefiles(config, gemfile, procfile)

      hello_rb = %q(
require 'sinatra'

get '/' do
  "Hello World!"
end
)
      File.write File.join(@app_path, 'hello.rb'), hello_rb
      sleep 0.3

    end

  end

  def local_testrun()
    r = IO.popen("bundle exec rackup -p 9292 config.ru")
    puts 'r: ' + r.inspect if @debug
    sleep 2

    s = URI.open('http://127.0.0.1:9292').read
    sleep 1

    Process.kill('QUIT', r.pid)

    puts 'SUCCESS! Ready to deploy' if s == "Hello World!"
  end

  def wipe_clean(setup=nil)

    rm File.join(@app_path, 'hello.rb')
    super(setup)

  end

end

class HerokuWhiz

  def initialize(dir: '.', template: 'rack', appname: File.basename(Dir.pwd),
        verbose: true, debug: false)

    @dir, @template, @appname, @verbose = dir, template, appname, verbose

    @app_path = File.join(@dir, @appname)
    FileUtils.chdir @app_path if File.exists? @app_path

    case @template.to_sym
    when :rack
      @tapp = WhizBase.new @app_path, verbose: verbose, debug: debug
    when :sinatra
      @tapp = SinatraWhiz.new @app_path, verbose: verbose, debug: debug
    end

  end

  def app_url()

    s = "https://#{heroku_app()}.herokuapp.com/"

    Clipboard.copy s
    puts 'app URL copied to clipboard.'

    return s

  end

  def app_open()
    `heroku open`
  end

  def create(add: nil)

    return unless @tapp

    @tapp.create add: add

    # build
    `bundle install`
    sleep 1

  end

  def goto(target)

    case target.to_sym
    when :apps
      Launchy.open("https://dashboard.heroku.com/apps")
    when :docs
      Launchy.open('https://devcenter.heroku.com/articles/rack')
    end

  end

  # currently only removes a file directory if there are no user created files
  #
  def wipe_clean(setup=:local)

    return unless @tapp

    @tapp.wipe_clean setup

  end

  def deploy()

    return unless @tapp

    @tapp.deploy

  end

  def local_run()

    return unless @tapp

    @tapp.local_run

  end

  def local_testrun()

    return unless @tapp

    @tapp.local_testrun()

  end

  private

  def heroku_app()
    s = `heroku config`
    s.lines.first.split[1] if s
  end

end
