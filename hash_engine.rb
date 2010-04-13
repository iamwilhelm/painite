module Evidence

  class HashEngine
    def initialize(name)
      @name = name
      clear
    end

    def size
      @evidence.size
    end
    
    # takes a hash of the evidence record
    def record(rec)
      @evidence << Hash[*rec.map { |k, v| [k.to_s, v]}.flatten]
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

    # clears the evidence
    def clear
      @evidence = []
    end

    def save(filepath = "#{@name}.rbm")
      File.open(filepath, 'w') do |f|
        f.write(Marshal.dump(@evidence))
      end
    end

    def load(filepath = "#{@name}.rbm")
      File.open("#{@name}.rbm") do |f|
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
