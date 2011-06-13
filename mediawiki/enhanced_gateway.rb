#!/usr/bin/env ruby

require 'rubygems'

require 'media_wiki'
require 'media_wiki/gateway'
require 'media_wiki/config'

module MediaWiki

  class EnhancedGateway < MediaWiki::Gateway

    # overrides the usual 'login' to provide retries upon timeout
    def login(user, pass)
      done = false
      while not done
        begin
          super(user, pass)
          done = true
        rescue SocketError
          puts "MediaWiki::Gateway::login -- caught SocketError, retrying..."
        rescue Errno::ETIMEDOUT
          puts "MediaWiki::Gateway::login -- caught Errno::ETIMEDOUT, retrying..."
        #rescue MediaWiki::Exception
        #  puts "MediaWiki::Gateway::login -- caught MediaWiki::Exception, retrying..."
        end
      end
    end

    def make_api_request_with_retry(form_data)
      res = nil
      while res.nil?
        begin
          res = make_api_request(form_data)
        rescue SocketError
          puts "MediaWiki::Gateway::make_api_request_with_retry -- caught SocketError, retrying..."
        rescue Errno::ETIMEDOUT
          puts "MediaWiki::Gateway::make_api_request_with_retry -- caught Errno::ETIMEDOUT, retrying..."
        rescue MediaWiki::Exception
          puts "MediaWiki::Gateway::make_api_request_with_retry -- caught MediaWiki::Exception, retrying..."
        end
      end

      return res
    end

    def get_with_retry(title)
      res = nil
      while res.nil?
        begin
          res = get(title)
        rescue SocketError
          puts "MediaWiki::Gateway::get_with_retry -- caught SocketError, retrying..."
        rescue Errno::ETIMEDOUT
          puts "MediaWiki::Gateway::get_with_retry -- caught Errno::ETIMEDOUT, retrying..."
        rescue MediaWiki::Exception
          puts "MediaWiki::Gateway::get_with_retry -- caught MediaWiki::Exception, retrying..."
        end
      end

      return res
    end
   
    def recent_changes(num_changes, end_time)
      form_data =
        {'action' => 'query',
        'list' => 'recentchanges'}
      form_data['rclimit'] = num_changes if !num_changes.nil?
      form_data['rcend'] = end_time.strftime("%Y%m%d%H%M%S") if !end_time.nil?

      res = make_api_request_with_retry(form_data)

      changes = REXML::XPath.match(res, "//rc").map { |x| { :type        => x.attributes["type"], 
                                                            :title       => x.attributes["title"], 
                                                            :timestamp   => x.attributes["timestamp"], 
                                                            :revision_id => x.attributes["revid"] } }
      return changes
    end

    def get_all_pages_in_category(category_title) # e.g., 'Category:Articles_with_hCards'
      form_data =
        {'action' => 'query',
        'list'    => 'categorymembers',
        'cmtitle' => category_title,
        'cmlimit' => '5000'}

      res = make_api_request_with_retry(form_data)

      titles = REXML::XPath.match(res, "//cm").map { |x| x.attributes["title"] }
      return titles
    end

    def get_page_revision(title)
      form_data =
        {'action' => 'query',
        'titles'  => title,
        'prop'    => 'revisions'}

      res = make_api_request_with_retry(form_data)

      rev_ids = REXML::XPath.match(res, "////rev").map { |x| x.attributes["revid"] }
      return rev_ids[0]
    end
   
    def exists(page_title)
      # used to be:
      #    return ! get_with_retry(page_title).nil?
      # but that was slower.

      form_data =
        {'action' => 'query',
        'titles'  => page_title,
        'prop'    => 'revisions'}

      res = make_api_request_with_retry(form_data)

      rev_ids = REXML::XPath.match(res, "////rev").map { |x| x.attributes["revid"] }
      return !( rev_ids.nil? or rev_ids.empty? )
    end

  end

end
