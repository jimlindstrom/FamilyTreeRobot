module MediaWiki

  class Page
    attr_accessor :revision_id

    def initialize(page_title, page_content, revision_id=0)
      @page_title   = page_title
      @page_content = page_content
      @revision_id  = revision_id

      @page_content.gsub!(/&lt;/,'<')
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
          val.gsub!(/<ref>[^<]*<\/ref>/, "") # clean up ref tags
  
          # store value
          person[key] = val
        end
      end
      return person
    end
  end
  
end
