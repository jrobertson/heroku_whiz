# Introducing the Heroku_whiz gem

In order to use this gem you will need to have signed up for a Heroku account. Also, you will need to demonstrate you can follow the steps on [how to deploy a simple Rack based Heroka app](https://devcenter.heroku.com/articles/rack#pure-rack-apps).

Example usage

    require 'heroku_whiz'

    hw = HerokuWhiz.new dir: '/home/james/heroku', template: 'rack', appname: 'hello2'

    hw.wipe_clean    # removes the previous local app file directory
    hw.create        # creates the local app file directory
    #hw.local_run    # runs the web app locally
    hw.local_testrun # tests the local web app returns the correct page
    hw.deploy        # creates the new app on Heroku
    hw.app_url       #=> e.g. https://frozen-dusk-65820.herokuapp.com/


## Resources

* heroku_whiz https://rubygems.org/gems/heroku_whiz

heroku app herokuapp deploy webhosting wizard gem
