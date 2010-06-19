module Evidence
  
  class BaseEngine
    include OverrideMethods
    
    override_methods :size, :clear, [:record, "rec"], :find_by, :count_by
    
    def initialize(name)
      @name = name
    end

  end

end
