# familytree_persondb_hash_spec.rb

require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'

describe Hash do

  before(:each) do

    @page_title  ="Dean Randall Lindstrom"
    @page_content=`cat "specs/testvectors/Dean Randall Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_dean = FamilyTree::Person.new(@page_title, @person_hash)

    @page_title  ="Eric Jacob Lindstrom"
    @page_content=`cat "specs/testvectors/Eric Jacob Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_eric = FamilyTree::Person.new(@page_title, @person_hash)

    @page_title  ="George Delphin Lindstrom"
    @page_content=`cat "specs/testvectors/George Delphin Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_george = FamilyTree::Person.new(@page_title, @person_hash)

    @page_title  ="Grace Kathryn Hoppe"
    @page_content=`cat "specs/testvectors/Grace Kathryn Hoppe.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_grace = FamilyTree::Person.new(@page_title, @person_hash)

    @page_title  ="James Brian Lindstrom"
    @page_content=`cat "specs/testvectors/James Brian Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_james = FamilyTree::Person.new(@page_title, @person_hash)

    @page_title  ="Jill Marie Linn"
    @page_content=`cat "specs/testvectors/Jill Marie Linn.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_jill = FamilyTree::Person.new(@page_title, @person_hash)

    @page_title  ="Randall Eugene Lindstrom"
    @page_content=`cat "specs/testvectors/Randall Eugene Lindstrom.html"`
    @page = MediaWiki::Page.new(@page_title, @page_content)
    @person_hash = @page.get_person
    @person_randall = FamilyTree::Person.new(@page_title, @person_hash)


  end

  describe "#escape_and_flattten" do

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_dean.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_eric.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_george.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_grace.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_james.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_jill.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

    it "flattens itself to a string and returns the string" do
      @cur_hash = @person_randall.person_hash
      eval(@cur_hash.escape_and_flatten.unescape).should == @cur_hash
    end

  end

end

