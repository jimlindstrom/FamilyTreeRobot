#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'logger'

require 'media_wiki'
require 'media_wiki/gateway'
require 'media_wiki/config'

module MediaWiki
  module FamilyTree

    class Gateway < MediaWiki::Gateway
     
      def recent_changes(num_changes, end_time)
        titles = []
        form_data =
          {'action' => 'query',
          'list' => 'recentchanges'}
        if !num_changes.nil?
          form_data['rclimit'] = num_changes
          #puts "form_data['rclimit'] = " + String(num_changes)
        end
        if !end_time.nil?
          form_data['rcend'] = end_time.strftime("%Y%m%d%H%M%S")
          #puts "form_data['rcend'] = " + end_time.strftime("%Y%m%d%H%M%S")
        end
        res = make_api_request(form_data)
        #puts "res: " + String(res) + "."
        titles = REXML::XPath.match(res, "//rc").map { |x| x.attributes["title"] }
        titles
      end

      def get_all_person_pages
        titles = []
        form_data =
          {'action' => 'query',
          'list' => 'categorymembers',
          'cmtitle' => 'Category:Articles_with_hCards',
          'cmlimit' => '5000'}
        res = make_api_request(form_data)
        titles = REXML::XPath.match(res, "//cm").map { |x| x.attributes["title"] }
        titles
      end
     
    end
  end

end
