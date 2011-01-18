#!/usr/bin/ruby

require 'mediawiki/familytree/robot'

# Mediawiki host & URL
base_url           = "http://jimlindstrom.com"
normal_prefix      = "/mediawiki"
special_prefix     = "/mediawiki"

# Robot credentials on mediawiki
user               = "robot"
pass               = "robotpass"

# filename where person DB is stored
person_db_filename = "person_db.pstore"

robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix, person_db_filename)

robot.start

puts "Press Enter to quit..."
gets

robot.stop

