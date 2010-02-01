class Object
  def P(vars, *vals)
    P.prob(vars, *vals)
  end
end

class P
  class << self
    attr_reader :records

    def prob(var_expr, *vals)
      randvars, condvars = parse(var_expr, *vals)

      # if available
      #   total = totalcache["condvars"]
      #   num = numcache["condvars"]["randvars"]

      totalset = filter_by(@records, condvars)
      numset = filter_by(totalset, randvars)
      return indep_joint_prob(randars) if numset.empty?

      num = numset.length.to_f
      total = totalset.length.to_f
      return (total == 0) ? 0 : num / total
    end
    
    def record(rec)
      clear unless @records
      @records << Hash[*rec.map { |k, v| [k.to_s, v]}.flatten]
      return self
    end

    def clear
      @records = []
    end

    def save(filepath = "pspace.rbm")
      File.open(filepath, 'w') do |f|
        f.write(Marshal.dump(@records))
      end
    end

    def load(filepath = "pspace.rbm")
      File.open("pspace.rbm") do |f|
        @records = Marshal.load(f.read)
      end
    end
    
    private

    # if we can't find anything, we assume indepencence and
    # multiply the prob of individual values
    def indep_joint_prob(randvar)
      randvars.inject(1) do |t, randvar|
        # to avoid infinite loops
        if filter_by(@records, randvar).empty? and randvars.length == 1
          t *= 1e-10 # assume a small probability so it's not zero
        else
          t *= prob(*randvar)
        end
      end
    end
    
    def filter_by(records, constraints)
      records.select do |rec|
        # make sure all constraints of fulfilled
        constraints.all? do |name, value|
          # turn single values into arrays then see if any of them the contraint
          [*value].any? { |v| rec.fetch(name, nil) == v }
        end
      end
    end
    
    def parse(expression, *values)
      # expand repeating variables
      # begin
      #   md = expression.match(/(\w+)\[(\d+)\]/)
      #   expression.sub!(/(\w+)\[(\d+)\]/, ([md[1]] * md[2].to_i) * ",") if md
      # end until md.nil?

      # then split long the given bar as well as all the join variable
      # for both random variables and conditional random variables
      randvars, condvars = expression.to_s.split(/\s*\|\s*/).map { |e| e.split(/\s*,\s*/) }
      condvars ||= []
      varvals = values[0..randvars.length - 1]
      givvals = values[(randvars.length)..(randvars.length + condvars.length)] || []
      
      return randvars.zip(varvals), condvars.zip(givvals)
    end
  end
end

