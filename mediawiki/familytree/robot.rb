#!/usr/bin/ruby

require 'mediawiki/familytree/gateway'
require 'mediawiki/page'

module MediaWiki
  module FamilyTree
    class Robot
      TMP_PAGE = '/tmp/pageidx.hmtl'
      AGENT_STR = 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.4) Gecko/20100513 Firefox/3.6.4'
      API_SUFFIX = '/api.php'
      LOGIN_SUFFIX = '/index.php?title=Special:UserLogin'
      NORMAL_PAGE_SUFFIX = '/index.php?title='
    
      def initialize(base_url, normal_prefix, special_prefix)
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
    
      end
      
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
    
      def main_loop
        prev_time  = Time.new.getgm
        while true
          cur_time  = Time.new.getgm
    
          titles = recent_changes(0,prev_time)
          if !titles.nil? and !titles.empty?
            change_callback(titles)
          else
            puts "no changes."
          end
    
          sleep 60.0      
          prev_time = cur_time
        end
      end
    
      def change_callback(titles)
        puts "Change callback.  Titles = " + titles.join(',')
      end
    
      def get(page_title)
        page_content = @mw.get(page_title)
        if page_content.nil?
          return nil
        end
        return MediaWiki::Page.new(page_title, page_content)
      end
    
    end

  end
  
end
