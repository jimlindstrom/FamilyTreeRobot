#!/usr/bin/env ruby

require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'
require './familytree/treehelpers'


#db_type = :pstore
#db_opts = {:filename => "person_db.pstore"}
db_type = :postgres
db_opts = {:host => 'localhost',
           :port => nil,
           :options => nil,
           :tty => nil,
           :dbname => 'people',
           :user => 'jim',
           :pass => 'password'}

@person_db = FamilyTree::PersonDB.create(db_type, db_opts)
#myancestors = @person_db.ancestors_of("Dean Randall Lindstrom")
myancestors = @person_db.ancestors_of("James Brian Lindstrom", 20)
#myancestors = @person_db.ancestors_of("Jennifer Robins Bernstein")

puts '<html>'
puts '<head>'
puts '<meta charset="utf-8">'
puts '</head>'
puts '<body>'
puts FamilyTree::TreeHelpers.get_nested_relative_string(myancestors)
puts '</body>'
puts '</html>'
