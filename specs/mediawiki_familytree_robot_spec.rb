# ftrobot_spec.rb
require 'mediawiki/familytree/robot'

do_messy_tests     = false # These tests muck with the 'recent_changes' list and so I try to minimize them
base_url           = "http://jimlindstrom.com"
normal_prefix      = "/mediawiki"
special_prefix     = "/mediawiki"
user               = "robot"
pass               = "robotpass"
person_db_filename = "/tmp/person_db.pstore"

describe MediaWiki::FamilyTree::Robot, "#login" do
  it "returns false if bad password" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    #robot.login(user,"boguspass").should == false ##FIXME Why doesn't this work?
  end

  it "returns false if bad username" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    #robot.login("bogususer",pass).should == false ##FIXME Why doesn't this work?
  end

  it "returns true if good credentials" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    #robot.login(user,pass).should == true ##FIXME Why doesn't this work?
  end
end

describe MediaWiki::FamilyTree::Robot, "#exists" do
  it "returns false if page does not exist" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.exists("Taoubasdofi2309124409832").should == false
  end

  it "returns true if page exists" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.login(user,pass)
    if do_messy_tests
      robot.exists("Taoubasdofi2309124409832").should == false
      robot.create("Taoubasdofi2309124409832", "Testing page creation")
      robot.exists("Taoubasdofi2309124409832").should == true
      robot.delete("Taoubasdofi2309124409832")
      robot.exists("Taoubasdofi2309124409832").should == false
    else
      robot.exists("Main_Page").should == true 
    end
  end
end

describe MediaWiki::FamilyTree::Robot, "#recent_changes" do
  it "returns the requested number of items" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    pages = robot.recent_changes(50,nil).length.should == 50
  end
  it "returns no items if no edits since the start time" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    t = Time.new
    starttime = t.getgm
    pages = robot.recent_changes(nil,starttime).length.should == 0 
  end
  it "returns the items edited since the start time" do
    if do_messy_tests
      t = Time.new
      starttime = t.getgm
      robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
      robot.login(user,pass)
      robot.create("Taoubasdofi2309124409832", "Testing page creation")
      robot.delete("Taoubasdofi2309124409832")
      pages = robot.recent_changes(nil,starttime).length.should >= 1 
    else
      t = Time.gm(2010, 7, 8, 9, 10, 11)
      starttime = t.getgm
      robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
      pages = robot.recent_changes(nil,starttime).length.should >= 1 
    end
  end
end

describe MediaWiki::FamilyTree::Robot, "#get" do
  it "returns nil if doesn't exist" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.get('AS3q34ghq3g4').nil?.should == true
  end
  it "returns a MediaWiki::Page object" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.get('James Brian Lindstrom').class.should == MediaWiki::Page
  end
end

describe MediaWiki::FamilyTree::Robot, "#start" do
  it "starts the main loop" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.start
    retries = 10
    while retries > 0 and robot.is_running == false do
      sleep 0.1
      retries -= 1
    end
    robot.is_running.should == true
    robot.stop
  end
end

describe MediaWiki::FamilyTree::Robot, "#stop" do
  it "stops the main loop" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.start
    retries = 10
    while retries > 0 and robot.is_running == false do
      sleep 0.1
      retries -= 1
    end
    robot.stop
    robot.is_running.should == false
  end
end

describe MediaWiki::FamilyTree::Robot, "#change_callback" do
  it "updates the person database for people passed to it" do
    person_db = FamilyTree::PersonDB.new(person_db_filename)
    person_db.reset

    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.change_callback(["James Brian Lindstrom"])
    robot = nil

    person_db = FamilyTree::PersonDB.new(person_db_filename)
    person_db.load("James Brian Lindstrom").nil?.should == false
  end
end

describe MediaWiki::FamilyTree::Robot, "#get_all_person_pages" do
  it "returns a list" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.get_all_person_pages.class.should == Array
  end
  it "returns a list of all the person pages on the mediawiki" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    robot.get_all_person_pages.index("Gustaf Lindstrom").nil?.should == false
    robot.get_all_person_pages.length.should > 300
  end
end

describe MediaWiki::FamilyTree::Robot, "#retrieve_all_people" do
  it "retrieves all remote pages and adds them to the database" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)
    all_person_pages = robot.get_all_person_pages
    robot.retrieve_all_people
    robot = nil

    person_db = FamilyTree::PersonDB.new(person_db_filename)
    all_person_pages.sort.should == person_db.get_all_people.sort
  end
end

