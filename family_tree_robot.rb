#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'thread'
require './familytree/robot'

# Read configuration
config     = YAML.load_file 'config/robot_config.yml'
mw_opts    = config["mw_opts"]
db_opts    = config["db_opts"]
robot_acct = config["robot_acct"]

# Useful for testing
Thread.abort_on_exception = true

robot = FamilyTree::Robot.new(mw_opts, db_opts)
#robot.login(robot_acct[:user], robot_acct[:pass])
if !robot.handle_args(ARGV)
  exit
end

puts "Starting robot.  Press enter to exit..."
robot.start
gets
robot.stop

