# familytree_persondb_spec.rb

require 'rubygems'
require 'yaml'
require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'

shared_examples_for 'FamilyTree::PersonDB' do

  before(:each) do

    @page_title  ="Dean Randall Lindstrom"
    @page_content=`cat "specs/testvectors/Dean Randall Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_dean = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    @page_title  ="Eric Jacob Lindstrom"
    @page_content=`cat "specs/testvectors/Eric Jacob Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_eric = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    @page_title  ="George Delphin Lindstrom"
    @page_content=`cat "specs/testvectors/George Delphin Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_george = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    @page_title  ="Geace Kathryn Hoppe"
    @page_content=`cat "specs/testvectors/Grace Kathryn Hoppe.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_grace = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    @page_title  ="James Brian Lindstrom"
    @page_content=`cat "specs/testvectors/James Brian Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_james = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    @page_title  ="Jill Marie Linn"
    @page_content=`cat "specs/testvectors/Jill Marie Linn.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_jill = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    @page_title  ="Randall Eugene Lindstrom"
    @page_content=`cat "specs/testvectors/Randall Eugene Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @revision_id = 0
    @person_randall = FamilyTree::Person.new(@page_title, @person_hash, @revision_id)

    create_persondb
  end
   
  describe "#save" do
    it "returns false if given something other than a person" do
      @person_db.save(nil).should == false
    end
    it "returns true if given a person" do
      @person_db.save(@person_james).should == true
    end
  end

  describe "#load" do
    it "returns nil if requested person is not in the DB" do
      @person_db.load("James RandomNameThatIsntInDB Lindstrom").should == nil
    end
    it "returns the person if requested person is not in the DB" do
      @person_db.save(@person_james)
      @person_db.load("James Brian Lindstrom").page_title.should == @person_james.page_title
    end
  end

  describe "#reset" do
    it "returns true" do
      @person_db.reset.should == true
    end
    it "clears the database" do
      @person_db.save(@person_james)
      @person_db.reset
      @person_db.load("James Brian Lindstrom").nil?.should == true
    end
  end
    
  describe "#exists" do
    it "returns false if person does not exist in the DB" do
      @person_db.exists("James Brian Lindstrom").should == false
    end
    it "returns true if person exists in the DB" do
      @person_db.save(@person_james)
      @person_db.exists("James Brian Lindstrom").should == true
    end
  end

  describe "#is_up_to_date" do
    it "returns false if person does not exist in the DB" do
      @person_db.is_up_to_date("James Brian Lindstrom", 10).should == false
    end
    it "returns false if person exists and its revision ID is older than the given one" do
      @person_db.save(@person_james)
      @person_db.is_up_to_date("James Brian Lindstrom", 10).should == false
    end
    it "returns true if person exists and its revision ID is at least as new than the given one" do
      @person_db.save(@person_james)
      @person_db.is_up_to_date("James Brian Lindstrom", 0).should == true
    end
  end

  describe "#ancestors_of" do
    it "returns empty list if person not in the database" do
      @person_db.ancestors_of("James Brian Lindstrom").empty?.should == true
    end

    it "only returns people" do
      @page_title  ="Richard Arscott"
      @page_content ="{{Needs_research}}\n\n{{Infobox person\n| name              = Richard Arscott\n| birth_date        = \n| birth_place       = Ashwater, Devon, England<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n| death_date        = 1437<ref>[[Visitation of the County of Devon in the Year 1620]] (p. 10)</ref>\n| death_place       = \n| resting_place     = \n| spouse            = Joane _____<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n| children          = [[John Arscott (1469)]]<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n| parents           = [[Robert Arscott]]<br />[[Joane Tilley]]<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n}}\n\nRichard's mother, Joane, is the daughter of Nicholas Tilley<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>.\n\nTo do: Mom/Grandfather may be trace-able...\n\n==Notes==\n{{Reflist}}\n" 
      @page = MediaWiki::Page.new(@page_title, @page_content)
      @person_hash = @page.get_person
      @person_richard = FamilyTree::Person.new(@page_title, @person_hash)
      @person_richard.parents.should == ["Robert Arscott","Joane Tilley"]
      #puts "Parents: " + @person_richard.parents.join(",")
    end
    it "returns a tree of the page_titles (strings) of people who are ancestors of the person" do
      @person_db.save(@person_james)
      @person_db.save(@person_jill)
      @person_db.save(@person_randall)
      #@person_db.save(@person_grace)
      #@person_db.save(@person_george)
      @person_db.save(@person_eric)
      @person_db.save(@person_dean)
      @person_db.ancestors_of("James Brian Lindstrom").should == ["James Brian Lindstrom",["Randall Eugene Lindstrom",["Dean Randall Lindstrom",["George Delphin Lindstrom"],["Aline Kleone Vaughn"]],["Peggy Jeanette Schneider"],["Janice Lois Schepler"]],["Jill Marie Linn",["Leslie Leonard Linn"],["Grace Kathryn Hoppe"]]]
    end
    it "returns only as many levels as requested" do
      @person_db.save(@person_james)
      @person_db.save(@person_jill)
      @person_db.save(@person_randall)
      #@person_db.save(@person_grace)
      #@person_db.save(@person_george)
      @person_db.save(@person_eric)
      @person_db.save(@person_dean)
      @person_db.ancestors_of("James Brian Lindstrom",1).should == ["James Brian Lindstrom",["Randall Eugene Lindstrom"],["Jill Marie Linn"]]
    end
  end

  describe "#descendants_of" do
    it "returns empty list if person not in the database" do
      @person_db.descendants_of("James Brian Lindstrom").empty?.should == true
    end
    it "returns just the person if person has no children" do
      @person_db.save(@person_james)
      @person_db.save(@person_randall)
      @person_db.save(@person_jill)
      @person_db.save(@person_grace)
      @person_db.save(@person_george)
      @person_db.save(@person_eric)
      @person_db.save(@person_dean)
      @person_db.descendants_of("Eric Jacob Lindstrom").should == ["Eric Jacob Lindstrom"]
    end
    it "returns a list of the page_titles (strings) of people who are descendants of the person given" do
      @person_db.save(@person_james)
      @person_db.save(@person_jill)
      @person_db.save(@person_randall)
      @person_db.save(@person_grace)
      @person_db.save(@person_george)
      @person_db.save(@person_eric)
      @person_db.save(@person_dean)
      @person_db.descendants_of("George Delphin Lindstrom").string_tree_sort.should == ["George Delphin Lindstrom", ["Dean Randall Lindstrom", ["Randall Eugene Lindstrom", ["James Brian Lindstrom"], ["Eric Jacob Lindstrom"]], ["William Darrel Lindstrom"], ["Shirley Jean Lindstrom"], ["Cynthia Lee Lindstrom"], ["Tonja Sue Lindstrom"]], ["Larry George Lindstrom"]].string_tree_sort
    end
    it "returns only as many levels as requested" do
      @person_db.save(@person_james)
      @person_db.save(@person_jill)
      @person_db.save(@person_randall)
      @person_db.save(@person_grace)
      @person_db.save(@person_george)
      @person_db.save(@person_eric)
      @person_db.save(@person_dean)
      @person_db.descendants_of("George Delphin Lindstrom", 2).string_tree_sort.should == ["George Delphin Lindstrom", ["Dean Randall Lindstrom", ["Randall Eugene Lindstrom"], ["William Darrel Lindstrom"], ["Shirley Jean Lindstrom"], ["Cynthia Lee Lindstrom"], ["Tonja Sue Lindstrom"]], ["Larry George Lindstrom"]].string_tree_sort
    end
  end

  describe "#get_all_people" do
    it "returns empty list if empty database" do
      @person_db.get_all_people.empty?.should == true
    end
    it "returns a tree of the page_titles (strings) of people who are ancestors of the person" do
      @person_db.save(@person_james)
      @person_db.save(@person_jill)
      @person_db.save(@person_dean)
      @person_db.get_all_people.sort.should == ["Dean Randall Lindstrom", "James Brian Lindstrom", "Jill Marie Linn"]
    end
  end

end

describe FamilyTree::PStorePersonDB do

  let(:create_persondb) {

    # Read configuration
    config      = YAML.load_file 'config/robot_config_pstore.yml'
    #@mw_opts    = config["mw_opts"]
    @db_opts    = config["db_opts"]
    #@robot_acct = config["robot_acct"]

    @person_db = FamilyTree::PersonDB.create(@db_opts)
    @person_db.reset
  }

  it_should_behave_like 'FamilyTree::PersonDB'

end
  
describe FamilyTree::PStorePersonDB do

  let(:create_persondb) {

    # Read configuration
    config      = YAML.load_file 'config/robot_config_pstore.yml'
    #@mw_opts    = config["mw_opts"]
    @db_opts    = config["db_opts"]
    #@robot_acct = config["robot_acct"]

    @person_db = FamilyTree::PersonDB.create(@db_opts)
    @person_db.reset
  }

  it_should_behave_like 'FamilyTree::PersonDB'

end

