module FamilyTree

  class Person
    attr_accessor :page_title, :person_hash, :revision_id, :name, :spouses, :children, :parents, :birth_date, :death_date, :residences, :birth_place, :death_place, :resting_place

    attr_accessor :precomputed_ancestors, :precomputed_descendants
  
    def initialize(page_title, person_hash, revision_id=0)
      self.page_title  = page_title
      self.person_hash = person_hash
      self.revision_id = revision_id
  
      if !self.person_hash.nil?
        parse_name()
        parse_relationships()
        parse_dates()
        parse_locations()
      end
    end
  
    private
  
    def parse_name
      # parse the name
      if !self.person_hash["name"].nil?
        self.name = self.person_hash['name']
      end
    end
  
    def parse_relationships
      # parse the children
      person_link_regex = /\[\[([^\]]*)\]\]/
      if !self.person_hash["children"].nil?
        children_uids = self.person_hash["children"].scan(person_link_regex)
        self.children = []
        for i in children_uids
          i[0].gsub!(/\|.*/,"")
          self.children.push(i[0])
        end
      else
        self.children = []
      end
  
      # parse the parents
      person_link_regex = /\[\[([^\]]*)\]\]/
      if !self.person_hash["parents"].nil?
        parents_uids = self.person_hash["parents"].scan(person_link_regex)
        self.parents = []
        for i in parents_uids
          i[0].gsub!(/\|.*/,"")
          self.parents.push(i[0])
        end
      else
        self.parents = []
      end
  
      # parse the spouses
      person_link_regex = /\[\[([^\]]*)\]\]/
      if !self.person_hash["spouse"].nil?
        spouses_uids = self.person_hash["spouse"].scan(person_link_regex)
        self.spouses = []
        for i in spouses_uids
          i[0].gsub!(/\|.*/,"")
          self.spouses.push(i[0])
        end
      else
        self.spouses = []
      end
    end
  
    def parse_dates
      if !self.person_hash["birth_date"].nil?
          if self.person_hash["birth_date"] =~ /[A-Za-z]\|([0-9]*)\|([0-9]*)\|([0-9]*)\}/
              self.birth_date = {:year => $1.to_i, :mon => $2.to_i, :day => $3.to_i}
          elsif self.person_hash["birth_date"] =~ /([0-9]{4})/
              self.birth_date = {:year => $1.to_i, :mon => nil,     :day => nil    }
          else
              self.birth_date = nil
          end
  
      end
  
      if !self.person_hash["death_date"].nil?
          if self.person_hash["death_date"] =~ /[A-Za-z]\|([0-9]*)\|([0-9]*)\|([0-9]*)\}/
              self.death_date = {:year => $1.to_i, :mon => $2.to_i, :day => $3.to_i}
          elsif self.person_hash["death_date"] =~ /([0-9]{4})/
              self.death_date = {:year => $1.to_i, :mon => nil,     :day => nil    }
          else
              self.death_date = nil
          end
      else
          self.death_date = nil
      end
    end
  
    def parse_locations
      if self.person_hash["residence"]
        residences = self.person_hash["residence"].scan(/\{\{([^\}]*)\}\}/)
        self.residences = []
        for cur_residence in residences
          if cur_residence[0] =~ /lived_at *\|([^\|]*)\|([^\|]*)/
            loc_str  = $1
            date_str = $2
  
            if !loc_str.nil?
              loc_str.gsub!(/[\[\]]/, "")
              if !loc_str.nil?
                loc_str.gsub!(/\([^\)]*\)/, "")
                if date_str =~ /([0-9]{4})/ # FIXME: do more sophisticated searching here...
                  date_arr = {:year => $1.to_i, :mon => nil, :day => nil}
                  self.residences.push({:loc => loc_str, :date => date_arr})
                end
              end
            end
          end
        end
      end
  
      if !self.person_hash["birth_place"].nil?
        self.birth_place = self.person_hash['birth_place']
        self.birth_place.gsub!(/\[\[([^\|]*)\|([^\]]*)\]\]/, '\2')
        self.birth_place.gsub!(/\[\[([^\|]*)\]\]/, '\1')
      end
  
      if !self.person_hash["death_place"].nil?
        self.death_place = self.person_hash['death_place']
        self.death_place.gsub!(/\[\[([^\|]*)\|([^\]]*)\]\]/, '\2')
        self.death_place.gsub!(/\[\[([^\|]*)\]\]/, '\1')
      end
  
      if !self.person_hash["resting_place"].nil?
        self.resting_place = self.person_hash['resting_place']
        self.resting_place.gsub!(/\[\[([^\|]*)\|([^\]]*)\]\]/, '\2')
        self.resting_place.gsub!(/\[\[([^\|]*)\]\]/, '\1')
      end
  
    end
  
  end

end
