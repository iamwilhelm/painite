module Evidence

  class HashEngine < BaseEngine
    
    # required interface methods
    
    def size
      @evidence.size
    end

    # clears the evidence
    def clear
      @evidence = []
    end

    # takes a hash of the evidence record
    def record(record)
      @evidence << Hash[*record.map { |k, v| [k.to_s, v]}.flatten]
      return self
    end

    def find_by(*constraint_set)
      @evidence.select do |record|
        # make sure all constraints are fulfilled
        constraint_set.map do |constraints|
          satisfied?(record, constraints)
        end.all?
      end
    end

    def count_by(*constraint_set)
      find_by(*constraint_set).length.to_f
    end

    # methods specific to hash engine

    def save(filepath = nil)
      filepath ||= "#{@name}.rbm"
      File.open(filepath, 'w') do |f|
        f.write(Marshal.dump(@evidence))
      end
    end

    def load(filepath = nil)
      filepath ||= "#{@name}.rbm"
      File.open(filepath) do |f|
        @evidence = Marshal.load(f.read)
      end
    end

    private
    def satisfied?(record, constraints)
      constraints.all? do |name, value|
        # turn single values into arrays then see if any of them the contraint
        [*value].any? { |v| record.fetch(name, nil) == v }
      end
    end
  end
  
end
