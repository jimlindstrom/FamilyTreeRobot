require 'rubygems'
require 'pstore'

require './familytree/person'
require './familytree/persondb_base'

module FamilyTree

  class PStorePersonDB < PersonDB
  
    def initialize(opts)
      @db_filename = opts[:filename]
      @store = PStore.new(opts[:filename])
    end

    def save(person)
      if person.class != FamilyTree::Person
        return false
      end
      @store.transaction do
        @store[person.page_title] = person
      end
      return true
    end

    def load(page_title)
      ret = nil
      @store.transaction do
        ret = @store[page_title]
      end
      return ret
    end

    def reset
      @store = nil # not sure if we need to delete the in-memory copy while we delete the file-based copy, but here's a try...
      begin
        File.delete(@db_filename)
      rescue Errno::ENOENT
      end
      @store = PStore.new(@db_filename)
      return true
    end

    def get_all_people
      all_people = []
      @store.transaction do
        all_people = @store.roots
      end
      all_people
    end

    def exists(page_title)
      return !load(page_title).nil?
    end

    def is_up_to_date(page_title, revision_id)
      person = load(page_title)
      return false if person.nil?

      return person.revision_id >= revision_id
    end

    def get_timestamp # returns the time the DB was last updated
      if File.exists?(@db_filename)
        return File.mtime(@db_filename)
      end
      return Time.at(0)
    end

    def invalidate_ancestry_caches()
      all_people_names = get_all_people
      all_people_names.each do |cur_person_name|
        cur_person = load(cur_person_name)
        cur_person.precomputed_ancestors = nil
        cur_person.precomputed_descendants = nil
        save(cur_person)
      end
    end

    def ancestors_of(page_title, max_depth=10000)
      cur_person = load(page_title)
      return [] if cur_person.nil?

      if cur_person.precomputed_ancestors.nil?

        ancestors = [cur_person.page_title]
        if max_depth > 0
          for cur_parent in cur_person.parents
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
  
        cur_person.precomputed_ancestors = ancestors
        save(cur_person)

      else

        ancestors = cur_person.precomputed_ancestors

      end

      return ancestors
    end

    def descendants_of(page_title, max_depth=10000)
      cur_person = load(page_title)
      return [] if cur_person.nil?

      descendants = []
      if cur_person.precomputed_descendants.nil?

        descendants = [cur_person.page_title]
        if max_depth > 0
          for cur_child in cur_person.children
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

        cur_person.precomputed_descendants = descendants
        save(cur_person)

      else
        descendants = cur_person.precomputed_descendants
      end

      return descendants
    end
  
  end

end
