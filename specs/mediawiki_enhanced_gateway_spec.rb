# mediawiki_enhanced_gateway_spec.rb

require 'rubygems'
require 'yaml'
require './mediawiki/enhanced_gateway'
require './mediawiki/page'
require './familytree/persondb'

DO_MESSY_TESTS = false # These tests muck with the 'recent_changes' list and so I try to minimize them

API_SUFFIX     = '/api.php'

def rand_alphanumeric_str(len)
  o =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten;  
  (0..len).map{ o[rand(o.length)]  }.join;
end

describe MediaWiki::EnhancedGateway do
   
  before(:each) do

    # Read configuration
    config      = YAML.load_file 'config/robot_config_pstore.yml'
    @mw_opts    = config["mw_opts"]
    @db_opts    = config["db_opts"]
    @robot_acct = config["robot_acct"]

    api_url = @mw_opts[:base_url] + @mw_opts[:normal_prefix] + API_SUFFIX
    @gateway = MediaWiki::EnhancedGateway.new(api_url, {:ignorewarnings=>1})

    @bogus_user = rand_alphanumeric_str(10)
    @bogus_password = rand_alphanumeric_str(10)

    @nonexistant_page = rand_alphanumeric_str(20)
    @existing_page = "Main_Page"

    @existing_category = "Category:Wikipedia_protected_templates"
    @page_in_existing_category = "Template:Navbox"
  end

  describe "#login" do
    it "throws MediaWiki::Unauthorized if bad password" do
      lambda {
        @gateway.login(@robot_acct[:user], @bogus_password)
      }.should raise_error(MediaWiki::Unauthorized)
    end
  
    it "throws MediaWiki::Unauthorized if bad username" do
      lambda {
        @gateway.login(@bogus_user, @robot_acct[:pass])
      }.should raise_error(MediaWiki::Unauthorized)
    end
  
    it "doesn't throw anything if good credentials" do
      lambda {
        @gateway.login(@robot_acct[:user], @robot_acct[:pass])
      }.should_not raise_error(MediaWiki::Unauthorized)
    end
  end

  describe "#exists" do
    it "returns false if page does not exist" do
      @gateway.exists(@nonexistant_page).should == false
    end
  
    it "returns true if page exists" do
      if DO_MESSY_TESTS
        @gateway.login(user,pass)
        @gateway.exists(@nonexistant_page).should == false
        @gateway.create(@nonexistant_page, "Testing page creation")
        @gateway.exists(@nonexistant_page).should == true
        @gateway.delete(@nonexistant_page)
        @gateway.exists(@nonexistant_page).should == false
      else
        @gateway.exists(@existing_page).should == true 
      end
    end
  end
  
  describe "#recent_changes" do
    it "returns the requested number of items" do
      pages = @gateway.recent_changes(50,nil).length.should == 50
    end

    it "returns no items if no edits since the start time" do
      t = Time.new
      starttime = t.getgm
      pages = @gateway.recent_changes(nil,starttime).length.should == 0 
    end

    it "returns the items edited since the start time" do
      if DO_MESSY_TESTS
        t = Time.new
        starttime = t.getgm
        @gateway.login(@robot_acct[:user], @robot_acct[:pass])
        @gateway.create(@nonexistant_page, "Testing page creation")
        @gateway.delete(@nonexistant_page)
        pages = @gateway.recent_changes(nil,starttime).length.should >= 1 
      else
        t = Time.gm(2010, 7, 8, 9, 10, 11)
        starttime = t.getgm
        @gateway.recent_changes(nil,starttime).length.should >= 1 
      end
    end

    it "returns a list of items that are hashes containing 'type', 'title', and 'revision_id' keys" do
      if DO_MESSY_TESTS
        t = Time.new
        starttime = t.getgm
        @gateway.login(@robot_acct[:user], @robot_acct[:pass])
        @gateway.create(@nonexistant_page, "Testing page creation")
        @gateway.recent_changes(nil,starttime).should == [ { :type => "new", :title => @nonexistant_page } ] # FIXME: needs to take into account revision_id
        @gateway.delete(@nonexistant_page)
      else
        @gateway.login(@robot_acct[:user], @robot_acct[:pass])
        @gateway.recent_changes(10,nil)[0].keys.should == [:type, :title, :revision_id]
      end
    end
  end
  
  describe "#get" do
    it "returns nil if doesn't exist" do
      @gateway.get(@nonexistant_page).nil?.should == true
    end
    it "returns a String object" do
      @gateway.get(@existing_page).class.should == String
    end
  end
   
  describe "#get_all_pages_in_category" do
    it "returns a list" do
      @gateway.get_all_pages_in_category(@existing_category).class.should == Array
    end
    it "returns a list of all the person pages on the mediawiki" do
      @gateway.get_all_pages_in_category(@existing_category).index(@page_in_existing_category).nil?.should == false
      @gateway.get_all_pages_in_category(@existing_category).length.should > 1
    end
  end
  
  describe "#retrieve_all_people" do
    it "retrieves all remote pages and adds them to the database" do
      if DO_MESSY_TESTS
        all_person_pages = robot.get_all_person_pages
        @gateway.retrieve_all_people
        robot = nil
    
        person_db = FamilyTree::PersonDB.create(@db_opts)
        all_person_pages.sort.should == person_db.get_all_people.sort
      end
    end
  end
  
end
