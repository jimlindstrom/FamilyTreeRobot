#!/usr/bin/env ruby

require 'thread'
require 'time'
require './mediawiki/enhanced_gateway'

module MediaWiki

  class Robot

    attr_accessor :mw

    API_SUFFIX = '/api.php'
    MAX_SIMULTANEOUS_THREADS = 10

    def initialize(mw_opts)
      api_url = mw_opts[:base_url] + mw_opts[:normal_prefix] + API_SUFFIX
      @mw = MediaWiki::EnhancedGateway.new(api_url, {:ignorewarnings=>1})

      @thread = nil

      @mainloop_sleep_secs = 5.0 # make this non-constant so that it can be overridden for testing
    end

    def start
      @thread = Thread.new { main_loop }
    end

    def stop
      @thread.kill
    end

    def is_running
      return false if @thread.nil?
      return true unless @thread.status.nil? or @thread.status == false
      return false
    end
 
  private

    def handle_single_change(change)
      raise "not implemented"
    end
 
    def handle_changes(changes)

      while not changes.empty?

        # spin up a bunch of threads to pull down these batches of changes in parallel
        threads = []
        for i in 1..MAX_SIMULTANEOUS_THREADS do
          if not changes.empty?

            threads << Thread.new(changes.shift) do |cur_change| 
              handle_single_change(cur_change)
            end

          end
        end
        threads.each { |aThread|  aThread.join }

      end

    end

    def main_loop

      # find the timestamp of the first change.  We only want NEW changes
      num_recent_changes = 500
      prev_time          = nil
      changes = @mw.recent_changes(num_recent_changes, prev_time)

      if !changes.nil? and !changes.empty?
        timestamp_of_first_change = changes[0][:timestamp].gsub(/[-T:]/, ' ').gsub(/Z/,'')
        prev_time = Time.strptime(timestamp_of_first_change, "%Y %m %d %H %M %S")
        prev_time = prev_time + 1 # move 1 sec past the last change
      end

      while true

        changes = @mw.recent_changes(num_recent_changes, prev_time)

        if !changes.nil? and !changes.empty?
          timestamp_of_first_change = changes[0][:timestamp].gsub(/[-T:]/, ' ').gsub(/Z/,'')
          prev_time = Time.strptime(timestamp_of_first_change, "%Y %m %d %H %M %S")
          prev_time = prev_time + 1 # move 1 sec past the last change

          handle_changes(changes)
        end
 
        sleep @mainloop_sleep_secs
      end
    end
    
  end

end
