#!/usr/bin/env ruby

require 'rubygems'
require 'thread'
require './familytree/robot'

# Robot credentials on mediawiki
ROBOT_ACCT = {:user => "robot",
              :pass => "robotpass"}

# Mediawiki host & URL
MW_OPTS = {:base_url       => "http://jimlindstrom.com",
           :normal_prefix  => "/mediawiki",
           :special_prefix => "/mediawiki"}

# filename where person DB is stored
DB_OPTS = {:type    => :postgres,
           :host    => 'localhost',
           :port    => nil,
           :options => nil,
           :tty     => nil,
           :dbname  => 'people',
           :user    => 'jim',
           :pass    => 'password'}

# Useful for testing
Thread.abort_on_exception = true

robot = FamilyTree::Robot.new(MW_OPTS, DB_OPTS)
#robot.login(ROBOT_ACCT[:user], ROBOT_ACCT[:pass])
if !robot.handle_args(ARGV)
  exit
end

puts "Starting robot.  Press enter to exit..."
robot.start
gets
robot.stop

