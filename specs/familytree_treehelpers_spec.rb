# familytree_persondb_spec.rb

require 'familytree/treehelpers'

describe FamilyTree::TreeHelpers do

  describe "#get_nested_relative_string" do
    it "flattens a tree into a string (the HTML nested list)" do
      FamilyTree::TreeHelpers.get_nested_relative_string(["George Delphin Lindstrom", ["Dean Randall Lindstrom", ["Randall Eugene Lindstrom", ["James Brian Lindstrom"], ["Eric Jacob Lindstrom"]], ["William Darrel Lindstrom"], ["Shirley Jean Lindstrom"], ["Cynthia Lee Lindstrom"], ["Tonja Sue Lindstrom"]], ["Larry George Lindstrom"]]).should == "George Delphin Lindstrom\n<ul>\n<li>Dean Randall Lindstrom\n<ul>\n<li>Randall Eugene Lindstrom\n<ul>\n<li>James Brian Lindstrom\n<li>Eric Jacob Lindstrom\n</ul>\n<li>William Darrel Lindstrom\n<li>Shirley Jean Lindstrom\n<li>Cynthia Lee Lindstrom\n<li>Tonja Sue Lindstrom\n</ul>\n<li>Larry George Lindstrom\n</ul>\n"
    end
  end

 
end
