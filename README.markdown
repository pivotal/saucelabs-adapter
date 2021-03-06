Saucelabs-Adapter
=================

Saucelabs-adapter provides the glue to connect Rails Selenium tests to saucelabs.com.

Currently it supports tests written using Webrat (via Test::Unit or Rspec), and JSUnit.

Getting Started - Webrat + Test::Unit test suites
------------------------------------------------

2. Install the gem:

        gem install saucelabs-adapter

3. Run the saucelabs_adapter generator in your project:

        $ cd your_rails_project
        $ script/generate saucelabs_adapter

4. If you will run against saucelabs (not just a local selenium rc server), enter your credentials.
   In config/selenium.yml, replace YOUR-SAUCELABS-USERNAME and YOUR-SAUCELABS-ACCESS-KEY with your saucelabs.com account information.

5. Install the webrat gem (>= 0.7.3) and the mongrel gem (so it can start your Rails app)

        $ gem install webrat
        $ gem install mongrel

6. To run against a local selenium server during development/test (not saucelabs), have an installed and running Selenium RC server
   (e.g. selenium-rc gem which provides 'selenium-rc' executable)
   
        $ gem install selenium-rc
        $ selenium-rc

5. Run Tests

    To run Selenium Test::Unit tests locally:

        rake selenium:local

    To run Selenium Test::Unit tests using saucelabs.com:

        rake selenium:sauce

RSpec + Rails
-------------

Testing with RSpec + Rails? No problem. Add the following to your spec_helper.rb

    ENV['SELENIUM_ENV'] ||= 'saucelabs'
    require 'selenium/client'
    require 'saucelabs_adapter'
    require 'saucelabs_adapter/rspec_adapter'

Note the environment variable must be set before the requiring of saucelabs_adapter.
This can be set to `'local'` to use a local selenium server.

Example Test
------------

*spec/views/index_spec.rb*

    require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

    describe 'Google Search' do
      it 'can find Google' do
        @browser.open '/'
        @browser.title.should eql('Google')
      end
    end

Tests are run as normal through `rake spec`. A tunnel is launched at the beginning of
each test, if those settings are not commented out.

Parallel Testing
----------------

Once you have `rake spec` set up to run your selenium tests by following instructions
above, you can parallelize them installing the `parallel_tests` plugin from
[http://github.com/grosser/parallel_tests][parallel]

From there, `rake parallel:spec[4]` runs your tests. One known issue is if
tunnels are being used, one tunnel is spawned up for each process, which may
be more lengthy.

  [parallel]: http://github.com/grosser/parallel_tests


Getting Started - JsUnit test suite
-----------------------------------

1. Prerequisites:

    Install the latest JsUnit from http://github.com/pivotal/jsunit

    JsUnit must be installed in RAILS_ROOT/public/jsunit as follows:

        public/jsunit/jsunit_jar/jsunit.jar      -- the compiled jar
        public/jsunit/jsunit/build.xml etc...    -- jsunit sources

2. Install the saucelabs-adapter gem:

        gem install saucelabs-adapter

3. Run the saucelabs_adapter generator in your project:

        cd your_project

        script/generate saucelabs_adapter --jsunit

4. Configure it.

    In config/selenium.yml, replace YOUR-SAUCELABS-USERNAME and
    YOUR-SAUCELABS-ACCESS-KEY with your saucelabs.com account information.

    Rename RAILS_ROOT/test/jsunit/jsunit_suite_example.rb to RAILS_ROOT/test/jsunit/jsunit_suite.rb
    and modify it if necessary:
    test_page needs to be set to the path under /public where your JsUnit test page (suite.html or similar) lives,
    with '/jsunit' prepended. e.g. if your JsUnit suite runs from RAILS_ROOT/public/javascripts/test-pages/suite.html
    then test_page needs to be set to '/jsunit/javascripts/test-pages/suite.html'.

5. Run Tests

    To run JsUnit tests locally:

        rake jsunit:selenium_rc:local

    To run JsUnit tests using saucelabs.com:

        rake jsunit:selenium_rc:sauce


What You Should See
-------------------

When running tests, intermixed with your test output you should see the following lines:

        [saucelabs-adapter] Setting up tunnel from Saucelabs (yourhostname-12345.com:80) to localhost:4000
        [saucelabs-adapter] Tunnel ID 717909c571b8319dc5ae708b689fd7f5 for yourhostname-12345.com is up.
        Started
        ....................
        [saucelabs-adapter] Shutting down tunnel to Saucelabs...
        [saucelabs-adapter] done.

In Case of Problems
-------------------
Try setting environment variable SAUCELABS\_ADAPTER\_DEBUG to "true".  This enables more verbose output.


Continuous Integration
----------------------
Sauce Labs now lets you set the name of a test job.
By default the SaucelabsAdapter will set this to the name of the machine it is currently running on,
however you may override this by setting the environment variable SAUCELABS\_JOB\_NAME.

This can be useful if you run many tests from the same CI machine and would like to differentiate between
them without actually viewing the video.

What it Does
------------

The saucelabs-adapter performs two functions when it detects you are running a test that will use saucelabs.com:

1. It sets up a Sauce Connect Tunnel before the test run starts and tears it down after the test ends.  This happens once for the entire test run.

2. It configures the selenium client to connect to the correct address at saucelabs.com.  This happens at the start of each test.

Resources
=========
* [The gem](http://gemcutter.org/gems/saucelabs-adapter)
* [Source code](http://github.com/pivotal/saucelabs-adapter)
* [Tracker project](http://www.pivotaltracker.com/projects/59050)
* [Canary CI build](http://cibuilder.pivotallabs.com:3333/builds/SaucelabsCanary)
* [Canary project source code](http://github.com/pivotal/saucelabs-canary)

NOTABLE CHANGES
===============

0.9.2
-----
- Revert incorrect deletion of require for jsunit\_selenium\_support.rb

0.9.1
-----
- Fix error with port when running webrat against local server

0.9.0
-----
- Added support for :sauce_connect_tunnel tunnel method, which uses 'sauce connect'
  from the 'sauce' gem.  This also introduces a dependency on the sauce gem.

0.8.7
-----
- No longer exits when the tunnel status is 'deploying'

0.8.5
-----
- Allow application_port to be a range of form: XXXX-YYYY, e.g. 4000-5000.  The SaucelabsAdapter will find an unused port in that range.
- Allow specification of the test framework in use.  If test_framework == :webrat and tunnel_mode == :sshtunnel, the generated unused port will also be written to tunnel_to_localhost_port

0.8
---
- Added new tunnel type SshTunnel (a generic reverse SSH tunnel), see selenium.yml for now to configure.
- Added jsunit_polling_interval_seconds configuratin option.

0.7.6
-----
- Added saucelabs_max_duration configuration option.

0.7.0
-----
- The gem has been reorganized to better conform with Gem best-practices.

- The rakefile generator has changed.  If you are upgrading, you will need to rerun the generator and overwrite lib/tasks/saucelabs_adapter.rake,
or just change line 1 of that file to read:

        require 'saucelabs_adapter/run_utils'

- The selenium.yml syntax has changed to break out all the saucelabs info into separate lines, and the tunnel method is now explicitly stated:

    - Old:
            selenium_browser_key: '{"username": "YOUR-SAUCELABS-USERNAME", "access-key": "YOUR-SAUCELABS-ACCESS-KEY", "os": "Linux", "browser": "firefox", "browser-version": "3."}'
            #
            localhost_app_server_port: "4000"
            tunnel_startup_timeout: 240

    - New:
            saucelabs_username: "YOUR-SAUCELABS-USERNAME"
            saucelabs_access_key: "YOUR-SAUCELABS-ACCESS-KEY"
            saucelabs_browser_os: "Linux"
            saucelabs_browser: "firefox"
            saucelabs_browser_version: "3."
            #
            tunnel_method: :saucetunnel
            tunnel_to_localhost_port: 4000
            tunnel_startup_timeout: 240
            
- The dependency on Python has been removed.
