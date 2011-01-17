module FamilyTree

  class TreeHelpers
  
    def self.print_nested_relative_list(a, print_li=false)
      str = ""

      if a.class == Array
        cur_elem = a.shift
        raise "Assertion failed !" unless cur_elem.class == String
        if print_li == true
          str += "<li>" + cur_elem + "\n"
        else
          str += cur_elem + "\n"
        end

        if !a.empty?
          str += "<ul>\n"
          while !a.empty? do
            cur_elem = a.shift
            raise "Assertion failed !" unless cur_elem.class == Array
            str += self.print_nested_relative_list(cur_elem, true)
          end
          str += "</ul>\n"
        end
      end

      return str
    end
  
  end

end
