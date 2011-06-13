require 'rubygems'
require 'pg'

require './familytree/person'
require './familytree/persondb_base'

### USED FOR COMPARING TREES (NESTED ARRAYS) OF STRINGS

class String

  def string_tree_compare
    self
  end

end

class Array

  def string_tree_compare
    return self.join("")
  end

  def string_tree_sort
    self.each do |elem| 
      if elem.class == Array
        elem = elem.string_tree_sort
      end
    end
    self.sort!{ |x,y| x.string_tree_compare <=> y.string_tree_compare }
  end

end

### USED FOR FLATTENING HASHES INTO STRINGS THAT CAN BE STORED IN POSTGRES

class String

  def single_escape 
    self.gsub(/'/, "\\\\'")
  end

  def double_escape 
    self.gsub(/"/, "\\\\\\\"")
  end

  def unescape
    self.gsub(/\\\\/, "\\\\")
  end

end
class Hash

  # turns a hash into a string that can be stored in postgres, then eval'ed back into the hash
  def escape_and_flatten
    substrings = []
    self.map do |k, v| 
      if k.class == Symbol
        k_str = ":" + String(k)
      else
        k_str = "\"" + String(k) + "\""
      end
      v_str = "\"" + v.double_escape.single_escape + "\""

      substrings.push(k_str + "=>" + v_str)
    end

    return "{" + substrings.join(",") + "}"
  end

end

module FamilyTree

  class PostgresPersonDB < PersonDB

    DEBUG = 0 # or 1

    def initialize(opts)
      # connect to DB
      @conn = nil
      begin
        @conn = PGconn.connect(opts[:host],opts[:port],opts[:options],opts[:tty],opts[:dbname],opts[:user],opts[:pass])
      rescue PGError
        printf(STDERR, "Connection to database '%s' failed.\n",dbname)
        exit(2)
      end
      begin
        @conn.set_notice_processor Proc.new {|message| nil }  if DEBUG == 0 # FIXME: DOESN'T WORK!
      rescue 
      end
    end

    def save(person)
      if person.class != FamilyTree::Person
        return false
      end

      begin
        sql = "INSERT INTO person (title, vals, revision_id) VALUES ('#{person.page_title.single_escape}', '#{person.person_hash.escape_and_flatten}', '#{person.revision_id}');"
        puts "executing: #{sql}" if DEBUG == 1
        @conn.exec(sql)
      rescue PGError
        sql = "UPDATE person SET vals='#{person.person_hash.escape_and_flatten}',revision_id='#{person.revision_id}' WHERE title='#{person.page_title.single_escape}';" 
        puts "executing: #{sql}" if DEBUG == 1
        @conn.exec(sql)
      end

      # Drop all parent-child relationships involving this person?
      sql = "DELETE FROM relationship WHERE child_title='#{person.page_title.single_escape}';"
      puts "executing: #{sql}" if DEBUG == 1

      sql = "DELETE FROM relationship WHERE parent_title='#{person.page_title.single_escape}';"
      puts "executing: #{sql}" if DEBUG == 1

      for cur_parent in person.parents
        sql = "INSERT INTO relationship (child_title, parent_title) VALUES ('#{person.page_title.single_escape}', '#{cur_parent.single_escape}');"
        puts "executing: #{sql}" if DEBUG == 1
        begin
          @conn.exec(sql)
        rescue PGError
          # ignore.  if this parent-child relationship already exists, that's perfectly fine
        end
      end

      for cur_child in person.children
        sql = "INSERT INTO relationship (child_title, parent_title) VALUES ('#{cur_child.single_escape}', '#{person.page_title.single_escape}');"
        puts "executing: #{sql}" if DEBUG == 1
        begin
          @conn.exec(sql)
        rescue PGError
          # ignore.  if this parent-child relationship already exists, that's perfectly fine
        end
      end

      return true
    end

    def load(page_title)
      sql = "SELECT title, vals, revision_id FROM person WHERE title='#{page_title.single_escape}';"
      puts "executing: #{sql}" if DEBUG == 1
      results = @conn.exec(sql)

      case results.num_tuples
      when 0
        return nil
      when 1
        person_hash_str = results.first["vals"]
        puts "parsing #{person_hash_str}" if DEBUG == 1
        person_hash = eval(person_hash_str)
        revision_id = results.first["revision_id"]
        return FamilyTree::Person.new(page_title, person_hash, revision_id)
      else
        raise "More than one result for same person?"
      end
    end

    def reset
      sql  = "DROP TABLE IF EXISTS relationship;"
      @conn.exec(sql)

      sql  = "DROP TABLE IF EXISTS person;"
      @conn.exec(sql)

      sql  = "CREATE TABLE person ("
      sql += "    title        varchar(100) PRIMARY KEY,"
      sql += "    vals         varchar,"
      sql += "    revision_id  integer"
      sql += ");"
      @conn.exec(sql)

      sql  = "CREATE TABLE relationship ("
      sql += "    parent_title varchar(100)," # NOTE: by not including "REFERENCES person,", this can be a bogus ID
      sql += "    child_title  varchar(100)," # NOTE: by not including "REFERENCES person,", this can be a bogus ID
      sql += "    UNIQUE (parent_title, child_title)"
      sql += ");"
      @conn.exec(sql)

      return true
    end

    def get_all_people
      sql = "SELECT title FROM person;"
      results = @conn.exec(sql)

      return results.map{ |x| x["title"] }
    end

    def exists(page_title)
      return !load(page_title).nil?
    end

    def is_up_to_date(page_title, revision_id)
      return load(page_title).revision_id >= revision_id
    end

    def get_timestamp # returns the time the DB was last updated
      # FIXME: not implemented!
      return Time.at(0)
    end

    def invalidate_ancestry_caches()
      # doesn't need to exist...
    end

    def ancestors_of(page_title, max_depth=10000)
      return [] if !exists(page_title)

      ancestors = [page_title]

      if max_depth > 0
        sql = "SELECT parent_title FROM relationship WHERE child_title='#{page_title.single_escape}';"
        results = @conn.exec(sql)
  
        results.each do |row|
          cur_parent = row["parent_title"]

          if exists(cur_parent)
            new_ancestors = ancestors_of(cur_parent, max_depth-1)
            if !new_ancestors.nil?
              ancestors.push(new_ancestors)
            end
          else
            ancestors.push([cur_parent])
          end

        end
  
      end

      return ancestors
    end

    def descendants_of(page_title, max_depth=10000)
      return [] if !exists(page_title)

      descendants = [page_title]

      if max_depth > 0
        sql = "SELECT child_title FROM relationship WHERE parent_title='#{page_title.single_escape}';"
        results = @conn.exec(sql)
  
        results.each do |row|
          cur_child = row["child_title"]

          if exists(cur_child)
            new_descendants = descendants_of(cur_child, max_depth-1)
            if !new_descendants.nil?
              descendants.push(new_descendants)
            end
          else
            descendants.push([cur_child])
          end

        end
  
      end

      return descendants
    end
  
  end

end
