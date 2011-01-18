# mediawikipage_spec.rb

require 'mediawiki/page'
require 'familytree/person'

describe FamilyTree::Person do

  before(:each) do
    @page_title='James Brian Lindstrom'
    @page_content=`cat "specs/testvectors/James Brian Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
  
    @person = FamilyTree::Person.new(@page_title, @person_hash)
  end
  
  describe "#page_title" do
    it "returns the page_title this person record came from" do
      @person.page_title.should == @page_title
    end
  end
    
  describe "#name" do
    it "returns the person's name" do
      @person.name.should == 'James ("Jim") Brian Lindstrom'
    end
  end

  describe "#spouses" do
    it "returns a list of the person's spouses" do
      @person.spouses.should == ['Jennifer Robins Bernstein']
    end
  end

  describe "#parents" do
    it "returns a list of the person's parents" do
      @person.parents.should == ['Randall Eugene Lindstrom', 'Jill Marie Linn']
    end
    it "only returns people" do
      @page_title  ="Richard Arscott"
      @page_content ="{{Needs_research}}\n\n{{Infobox person\n| name              = Richard Arscott\n| birth_date        = \n| birth_place       = Ashwater, Devon, England<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n| death_date        = 1437<ref>[[Visitation of the County of Devon in the Year 1620]] (p. 10)</ref>\n| death_place       = \n| resting_place     = \n| spouse            = Joane _____<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n| children          = [[John Arscott (1469)]]<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n| parents           = [[Robert Arscott]]<br />[[Joane Tilley]]<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>\n}}\n\nRichard's mother, Joane, is the daughter of Nicholas Tilley<ref>[[Visitation of the County of Devon in the Year 1620]]</ref>.\n\nTo do: Mom/Grandfather may be trace-able...\n\n==Notes==\n{{Reflist}}\n" 
      @page = MediaWiki::Page.new(@page_title, @page_content)
      @person_hash = @page.get_person
      @person_richard = FamilyTree::Person.new(@page_title, @person_hash)
      @person_richard.parents.should == ["Robert Arscott","Joane Tilley"]
    end
  end

  describe "#children" do
    it "returns a list of the person's children" do
      @person.children.should == []
    end
  end

  describe "#birth_date" do
    it "returns the person's birth date" do
      @person.birth_date.should == {:year => 1981, :mon => 1, :day => 2}
    end
  end

  describe "#death_date" do
    it "returns the person's death date" do
      @person.death_date.should == nil
    end
  end

  describe "#residences" do
    it "returns a list of the person's past and current residences" do
      @person.residences.should == [{:loc => "Bettendorf, IA", :date => {:year => 1984, :mon => nil, :day => nil} }, {:loc => "Champaign, IL",  :date => {:year => 1999, :mon => nil, :day => nil} }, {:loc => "Chicago, IL",    :date => {:year => 2003, :mon => nil, :day => nil} }, {:loc => "New York, NY",   :date => {:year => 2008, :mon => nil, :day => nil} }]
    end
  end
      
  describe "#birth_place" do
    it "returns the person's place of birth" do
      @person.birth_place.should == 'Waterloo, Iowa, USA'
    end
  end
   
  describe "#death_place" do
    it "returns the person's place of death" do
      @person.death_place.should == nil
    end
  end
   
  describe "#resting_place" do
    it "returns the person's resting place" do
      @person.resting_place.should == nil
    end
  end

end
