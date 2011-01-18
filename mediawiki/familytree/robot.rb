#!/usr/bin/ruby

require 'mediawiki/familytree/gateway'
require 'mediawiki/page'
require 'familytree/person'
require 'familytree/persondb'

module MediaWiki
  module FamilyTree
    class Robot
      AGENT_STR = 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.4) Gecko/20100513 Firefox/3.6.4'
      API_SUFFIX = '/api.php'
      MAINLOOP_SLEEP_SECS = 60.0
    
      def initialize(base_url, normal_prefix, special_prefix, person_db_filename)
        @base_url = base_url
        @normal_prefix = normal_prefix
        @special_prefix = special_prefix
    
        @agent = Mechanize.new {|agent| 
          agent.user_agent = AGENT_STR
          #agent.log = Logger.new(STDERR)
        }
        @agent.pre_connect_hooks << lambda { |params| params[:request]['Connection'] = 'keep-alive' }
        @agent.follow_meta_refresh = true
    
        @mw = MediaWiki::FamilyTree::Gateway.new(@base_url + @normal_prefix + API_SUFFIX)

        @person_db = ::FamilyTree::PersonDB.new(person_db_filename)

        @thread = nil
    
      end

      # these are primitives used internally and/or for specing other methods
      
      def login(user, pass)
        return @mw.login(user, pass)
      end
    
      def create(page_title, content)
        return @mw.create(page_title, content) ## FIXME: this page doesn't work....
      end
    
      def delete(page_title)
        return @mw.delete(page_title)
      end
    
      def exists(page_title)
        return ! @mw.get(page_title).nil?
      end
     
      def recent_changes(num_changes, end_time)
        return @mw.recent_changes(num_changes, end_time)
      end

      def get_all_person_pages
        return @mw.get_all_person_pages
      end
     
      def get(page_title)
        page_content = @mw.get(page_title)
        if page_content.nil?
          return nil
        end
        return MediaWiki::Page.new(page_title, page_content)
      end

      # these are methods you actually should use:

      def start
        @thread = Thread.new { main_loop }
      end

      def stop
        @thread.kill
      end

      def is_running
        return false if @thread.nil?
        return true unless @thread.status.nil? or @thread.status == false
        return false
      end
    
      def change_callback(titles)
        puts "MediaWiki::FamilyTree::Robot -- Change callback."
        titles.each { |cur_title|
          puts "\tRetrieving new copy of \"#{cur_title}\""
          @cur_page = get(cur_title)
          if @cur_page.contains_person
            puts "\tIs a person.  Saving to DB."
            @person_hash = @cur_page.get_person
            @person = ::FamilyTree::Person.new(cur_title, @person_hash)
            @person_db.save(@person)
          else
            puts "\tDoes not contain a person."
          end

        }
      end
 
      def retrieve_all_people
		person_list = get_all_person_pages
        change_callback(person_list)
      end

     private

      def main_loop
        prev_time  = Time.new.getgm
        while true
          cur_time  = Time.new.getgm
    
          titles = recent_changes(0,prev_time)
          if !titles.nil? and !titles.empty?
            change_callback(titles)
          else
            #puts "MediaWiki::FamilyTree::Robot -- no changes."
          end
    
          sleep MAINLOOP_SLEEP_SECS
          prev_time = cur_time
        end
      end
      
    end

  end
  
end
