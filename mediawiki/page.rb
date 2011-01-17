module MediaWiki

  class Page
    def initialize(page_title, page_content)
      @page_title   = page_title
      @page_content = page_content
    end
  
    def contains_person
      return ! @page_content.match(/\{\{Infobox *person/).nil?
    end
  
    def get_person
      if self.contains_person == false
        return nil
      end
  
      # FIXME: this is a really dumb parser. It'll get other infoboxes, etc.
      person = { }
      for cur_line in @page_content.split("\n")
        if cur_line =~ /\| *([A-Za-z0-9_]*) *= *(.*)/
          # parse
          key = $1
          val = $2
  
          # get rid of unwanted markup
          val.gsub!(/&lt;ref>[^\&]*&lt;\/ref>/, "") # clean up ref tags
  
          # store value
          person[key] = val
        end
      end
      return person
    end
  end
  
end
