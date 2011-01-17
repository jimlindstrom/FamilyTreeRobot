#!/usr/bin/ruby

require 'mediawiki/familytree/robot'

base_url       = "http://jimlindstrom.com"
normal_prefix  = "/mediawiki"
special_prefix = "/mediawiki"
user           = "robot"
pass           = "robotpass"

robot = MediaWiki::FamilyTree::Robot.new(base_url, normal_prefix, special_prefix)

robot.main_loop
