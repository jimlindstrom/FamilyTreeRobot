#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'
require './familytree/treehelpers'

# Read configuration
config      = YAML.load_file 'config/robot_config.yml'
@mw_opts    = config["mw_opts"]
@db_opts    = config["db_opts"]
@robot_acct = config["robot_acct"]

@person_db = FamilyTree::PersonDB.create(@db_opts)

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
