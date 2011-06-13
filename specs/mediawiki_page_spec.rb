# mediawikipage_spec.rb

require './mediawiki/page'

describe MediaWiki::Page, "#contains_person" do

  it "returns false if page does not contain a person" do
    page_title='James Brian Lindstrom'
    page_content='Some stuff\nSome more stuff\n\n\nASDF'

    page = MediaWiki::Page.new(page_title, page_content)
    page.contains_person.should == false
  end

  it "returns true if page contains a person" do
    page_title='James Brian Lindstrom'
    page_content=`cat "specs/testvectors/James Brian Lindstrom.html"`

    page = MediaWiki::Page.new(page_title, page_content)
    page.contains_person.should == true
  end
end

describe MediaWiki::Page, "#get_person" do

  it "returns nil if page does not contain a person" do
    page_title='James Brian Lindstrom'
    page_content='Some stuff\nSome more stuff\n\n\nASDF'

    page = MediaWiki::Page.new(page_title, page_content)
    page.get_person.nil?.should == true
  end

  it "returns hash if page contains a person" do
    page_title='James Brian Lindstrom'
    page_content=`cat "specs/testvectors/James Brian Lindstrom.html"`
    page = MediaWiki::Page.new(page_title, page_content)
    String(page.get_person.class).should == "Hash"
  end

  it "properly parses {key,value} pairs" do
    page_title='James Brian Lindstrom'
    page_content=`cat "specs/testvectors/James Brian Lindstrom.html"`
    page = MediaWiki::Page.new(page_title, page_content)
    person = page.get_person
    [person["name"],person["parents"]].should == ['James ("Jim") Brian Lindstrom','[[Randall Eugene Lindstrom]]<br />[[Jill Marie Linn]]']
  end

  it "removes <ref> tags" do
    page_title='James Brian Lindstrom'
    page_content=`cat "specs/testvectors/Eric Jacob Lindstrom.html"`
    page = MediaWiki::Page.new(page_title, page_content)
    person = page.get_person
    [person["name"],person["parents"]].should == ['Eric Jacob Lindstrom','[[Randall Eugene Lindstrom]]<br />[[Jill Marie Linn]]']
  end
end

