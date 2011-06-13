#!/usr/bin/env ruby

require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'
require './familytree/treehelpers'


#db_opts = {:type => :pstore, :filename => "person_db.pstore"}

db_opts = {:type => :postgres,
           :host => 'localhost',
           :port => nil,
           :options => nil,
           :tty => nil,
           :dbname => 'people',
           :user => 'jim',
           :pass => 'password'}

@person_db = FamilyTree::PersonDB.create(db_opts)

starting_person = ARGV.shift
myancestors = @person_db.ancestors_of(starting_person, 20)

puts '<html>'
puts '<head>'
puts '<meta charset="utf-8">'
puts '</head>'
puts '<body>'
puts FamilyTree::TreeHelpers.get_nested_relative_string(myancestors)
puts '</body>'
puts '</html>'
