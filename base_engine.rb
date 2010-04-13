require "override_methods"

module Evidence
  
  class BaseEngine
    include OverrideMethods
    
    override_methods :size, :clear, [:record, "rec"], :find_by
    
    def initialize(name)
      @name = name
      clear
    end
    
    def count_by(*constraint_set)
      find_by(*constraint_set).length.to_f
    end

  end

end
