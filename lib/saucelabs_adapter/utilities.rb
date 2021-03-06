module SaucelabsAdapter
  module Utilities

    def diagnostics_prefix
      @diagnostics_prefix ||= '[saucelabs-adapter]'
    end

    def say(what)
      STDOUT.puts "#{diagnostics_prefix} #{what}"
    end

    def debug(what, print_if_level_ge = 0)
      if ENV['SAUCELABS_ADAPTER_DEBUG']
        actual_level = ENV['SAUCELABS_ADAPTER_DEBUG'].to_i
        STDOUT.puts "#{diagnostics_prefix}   #{what}" if print_if_level_ge >= actual_level
      end
    end

    def raise_with_message(message)
      raise "#{diagnostics_prefix} #{message}"
    end

    def find_unused_port(hostname, range = (3000..5000))
      debug 'searching for unused port', 2
      range.each do |port|
        debug "trying #{hostname}:#{port}", 2
        begin
          socket = TCPSocket.new(hostname, port)
        rescue Errno::ECONNREFUSED
          debug "it's good, returning #{port}", 2
          return port
        ensure
          socket.close if socket
        end
      end
    end

    # parameters required when invoked by test_unit
    def start_mongrel(suite_name = {})
      pid_file = File.join(RAILS_ROOT, "tmp", "pids", "mongrel_selenium.pid")
      port = suite_name[:port] rescue @selenium_config.application_port
      say "Starting mongrel at #{pid_file}, port #{port}"
      system "mongrel_rails start -d --chdir='#{RAILS_ROOT}' --port=#{port} --environment=test --pid #{pid_file} %"
    end

    def kill_mongrel_if_needed(suite_name = {})
      mongrel_pid_file = File.join(RAILS_ROOT, "tmp", "pids", "mongrel_selenium.pid")
      if File.exists?(mongrel_pid_file)
        pid = File.read(mongrel_pid_file).to_i
        say "Killing mongrel at #{pid}"
        Process.kill("KILL", pid)
      end
      if File.exists?(mongrel_pid_file)
        FileUtils.rm(mongrel_pid_file)
      end
    end

    def setup_tunnel(suite_name = {})
      @tunnel = SaucelabsAdapter::Tunnel.factory(@selenium_config)
      @tunnel.start_tunnel
    end

    def teardown_tunnel(suite_name = {})
      @tunnel.shutdown
    end
  end
end
