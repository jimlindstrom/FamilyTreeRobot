require 'rubygems'
require 'pstore'

require "familytree/person"

module FamilyTree

  class PersonDB
  
    def initialize(db_filename)
      @db_filename = db_filename
      @store = PStore.new(db_filename)
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

    def exists(page_title)
      return !load(page_title).nil?
    end

    def ancestors_of(page_title, max_depth=10000)
      cur_person = load(page_title)
      return [] if cur_person.nil?

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

      return ancestors
    end

    def descendants_of(page_title, max_depth=10000)
      cur_person = load(page_title)
      return [] if cur_person.nil?

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

      return descendants
    end
  
  end

end
