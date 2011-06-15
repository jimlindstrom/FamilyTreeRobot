#!/usr/bin/env ruby

require 'rubygems'

require 'thread'

require 'mediawiki_robot'
require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'

module FamilyTree

  class Robot < MediawikiRobot::Robot

    HUGE_REVISION_ID = 100000
  
    def initialize(mw_opts, db_opts)
      super(mw_opts)
  
      @person_db = PersonDB.create(db_opts)

      @mutex = Mutex.new
    end

    def get_all_person_pages
      return @mw.get_all_pages_in_category('Category:Articles_with_hCards')
    end
   
    def get_page(page_title)
      page_content = @mw.get_with_retry(page_title)
      if page_content.nil?
        return nil
      end
      revision_id = @mw.get_page_revision(page_title)
      return MediaWiki::Page.new(page_title, page_content, revision_id)
    end
 
    def retrieve_all_people
      person_list = get_all_person_pages
      changes = person_list.map{ |x| { :type=>"new", :title=>x, :revision_id=>HUGE_REVISION_ID } }
      handle_changes(changes)
    end

    def handle_single_change(change) # Note: this may be called from multiple threads & needs to be threadsafe

      puts "\tChange called for \"#{change[:title]}\""
    
      if ( change[:type] == "new" ) or
         ( change[:type] == "edit" and !@person_db.exists(change[:title]) ) or
         ( change[:type] == "edit" and !@person_db.is_up_to_date(change[:title], change[:revision_id]) )
    
        puts "\tRetrieving new copy of \"#{change[:title]}\""
        @cur_page = get_page(change[:title])
        if @cur_page.contains_person
    
          @person_hash = @cur_page.get_person
          @person = ::FamilyTree::Person.new(change[:title], @person_hash, @cur_page.revision_id)
          @mutex.synchronize do
            @person_db.save(@person) # not threadsafe
          end
    
          @person_db.invalidate_ancestry_caches
    
        end # end if (is person)
    
      end # end if (is worth pursuing)
    
    end

    def show_usage
      puts "Usage:  family_tree_robot.rb [options]"
      puts "  -h                Show program usage"
      puts "  --help            Show program usage"
      puts "  --reset-db        Reset the database before beginning"
      puts "  --download-all    Re-download all page before beginning"
    end

    def handle_args(argv)
      while not argv.empty?
        case cur_arg = argv.shift
        when '-h', '--help'
          show_usage
          return false

        when '--reset-db'
          puts "Resetting database."
          @person_db.reset

        when '--download-all'
          puts "Retrieving all people."
          retrieve_all_people

        else
          puts "Unknown option: #{cur_arg}"
          return false
        end
      end

      return true
    end

  end

end
