require 'selenium_config'
require 'sauce_tunnel'

if defined?(ActiveSupport)

  module ::ActiveSupport
    class TestCase
      setup :configure_selenium # 'before_setup' callback from ActiveSupport::TestCase

      def configure_selenium
        selenium_config = SeleniumConfig.new(ENV['SELENIUM_ENV'])
        if defined?(Polonium)
          polonium_config = Polonium::Configuration.instance
          selenium_config.configure_polonium(polonium_config)
        else
          puts "[saucelabs-adapter] Polonium is not defined, skipping..."
        end
      end
    end
  end
end

if defined?(Test)

  class Test::Unit::UI::Console::TestRunner

    private

    def attach_to_mediator_with_sauce_tunnel
      attach_to_mediator_without_sauce_tunnel
      @selenium_config = SeleniumConfig.new(ENV['SELENIUM_ENV'])
      if @selenium_config['selenium_server_address'] == 'saucelabs.com'
        @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:setup_tunnel))
        @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:teardown_tunnel))
      end
    end

    alias_method_chain :attach_to_mediator, :sauce_tunnel unless private_method_defined?(:attach_to_mediator_without_sauce_tunnel)

    def setup_tunnel(suite_name)
      @tunnel = SauceTunnel.new(@selenium_config)
    end

    def teardown_tunnel(suite_name)
      @tunnel.shutdown
    end
  end
end