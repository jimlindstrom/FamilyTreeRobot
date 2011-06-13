# mediawiki_robot_spec.rb

require 'rubygems'
require 'yaml'
require './mediawiki/robot'

def wait_on_condition(max_retries, wait_time, condition)

  retries = max_retries
  while retries > 0 and condition.call==false do
    sleep wait_time
    retries -= 1
  end

end

def rand_alphanumeric_str(len)
  o =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten;  
  (0..len).map{ o[rand(o.length)]  }.join;
end

class RobotWithTestHarness < MediaWiki::Robot

  def initialize(mw_opts)
    super(mw_opts)

    @last_change = nil
    @mainloop_sleep_secs = 0.1
  end

  def handle_single_change(change)
    @last_change = change
  end

  def get_last_change
    return @last_change
  end

end

describe MediaWiki::Robot do
  
  before(:each) do

    # Read configuration
    config      = YAML.load_file 'config/robot_config_pstore.yml'
    @mw_opts    = config["mw_opts"]
    #@db_opts    = config["db_opts"]
    @robot_acct = config["robot_acct"]

    @robot = RobotWithTestHarness.new(@mw_opts)
  end
 
  describe "#start" do
    it "starts the main loop" do
      @robot.start

      wait_on_condition(10, 0.1, lambda { @robot.is_running } )

      @robot.is_running.should == true
      @robot.stop
    end

    it "doesn't call 'handle_single_change' unless a page on the mediawiki is changed" do
      @robot.start
      @robot.mw.login(@robot_acct[:user], @robot_acct[:pass])

      last_change = @robot.get_last_change
      last_change.nil?.should == true

      @robot.stop
    end

    it "calls 'handle_single_change' when a page on the mediawiki is changed" do
      @robot.start
      @robot.mw.login(@robot_acct[:user], @robot_acct[:pass])

      rand_page = rand_alphanumeric_str(20)
      @robot.mw.create(rand_page, "Testing robot functionality")

      sleep 0.5

      last_change = @robot.get_last_change
      last_change.nil?.should == false
      last_change.delete(:revision_id)
      last_change.delete(:timestamp)
      last_change.should == {:type=>"new", :title=>rand_page }
    
      @robot.mw.delete(rand_page)

      @robot.stop
    end
  end
 
  describe "#stop" do
    it "stops the main loop" do
      @robot.start
      sleep 0.1
      @robot.stop

      wait_on_condition(10, 0.1, lambda { !@robot.is_running } )

      @robot.is_running.should == false
    end
  end
 
end

