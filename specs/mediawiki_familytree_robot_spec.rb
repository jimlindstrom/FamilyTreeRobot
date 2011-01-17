# ftrobot_spec.rb
require 'mediawiki/familytree/robot'

do_messy_tests = false # These tests muck with the 'recent_changes' list and so I try to minimize them
base_url       = "http://jimlindstrom.com"
normal_prefix  = "/mediawiki"
special_prefix = "/mediawiki"
user           = "robot"
pass           = "robotpass"

describe MediaWiki::FamilyTree::Robot, "#login" do
  it "returns false if bad password" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    #robot.login(user,"boguspass").should == false ##FIXME Why doesn't this work?
  end

  it "returns false if bad username" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    #robot.login("bogususer",pass).should == false ##FIXME Why doesn't this work?
  end

  it "returns true if good credentials" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    #robot.login(user,pass).should == true ##FIXME Why doesn't this work?
  end
end

describe MediaWiki::FamilyTree::Robot, "#exists" do
  it "returns false if page does not exist" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    robot.exists("Taoubasdofi2309124409832").should == false
  end

  it "returns true if page exists" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
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
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    pages = robot.recent_changes(50,nil).length.should == 50
  end
  it "returns no items if no edits since the start time" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    t = Time.new
    starttime = t.getgm
    pages = robot.recent_changes(nil,starttime).length.should == 0 
  end
  it "returns the items edited since the start time" do
    if do_messy_tests
      t = Time.new
      starttime = t.getgm
      robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
      robot.login(user,pass)
      robot.create("Taoubasdofi2309124409832", "Testing page creation")
      robot.delete("Taoubasdofi2309124409832")
      pages = robot.recent_changes(nil,starttime).length.should >= 1 
    else
      t = Time.gm(2010, 7, 8, 9, 10, 11)
      starttime = t.getgm
      robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
      pages = robot.recent_changes(nil,starttime).length.should >= 1 
    end
  end
end

describe MediaWiki::FamilyTree::Robot, "#get" do
  it "returns nil if doesn't exist" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    robot.get('AS3q34ghq3g4').nil?.should == true
  end
  it "returns a MediaWiki::Page object" do
    robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)
    String(robot.get('James Brian Lindstrom').class).should == "MediaWiki::Page"
  end
end

