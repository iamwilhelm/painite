require 'rubygems'
require 'mongo'


module Evidence
  class MongoEngine < BaseEngine
    include Mongo

    def initialize(name)
      @db = Connection.new.db("painite")
      @collection = @db.collection(name)
      super
    end
    
    def size
      @collection.count
    end

    def clear
      @collection.remove
    end

    def record(record)
      @collection.insert(record)
    end

    def find_by(*constraint_set)
      # convert constraint_set to hash
      constraint_set.map! { |vars| convert_to_params(vars) }

      if constraint_set.length == 1
        @collection.find(constraint_set.first)
      else
        @collection.find(constraint_set.first.merge(constraint_set.last))
      end
    end

    def count_by(*constraint_set)
      find_by(*constraint_set).count
    end

    def group_by(*constraint_set)
      randvars, condvars = constraint_set
      
      # find distribution vectors
      distr_randvars = distributed_vars(randvars)
      randvars = specified_vars(randvars)

      distr_condvars = distributed_vars(condvars)
      condvars = specified_vars(condvars)
      
      constraint_params = [randvars, condvars].map { |vars| convert_to_params(vars) }
      constraints = constraint_params.first.merge(constraint_params.last)
      
      distr_results = @collection.group(distr_randvars, constraints, { :count => 0 },
                                        "function(obj, prev) { prev.count += 1; }")
      
      distr_results.map { |distr_count|
        count = distr_count.delete("count")
        key = distr_randvars.map { |rv| distr_count[rv] }
        [key, count]
      }
    end
    
    def save(filepath = nil)
      puts "Mongo doesn't need to save the database"
    end

    def load(filepath = nil)
      puts "Mongo doesn't need to load the database"
    end


    def distributed_vars(constraint)
      constraint.select { |rv| rv[1].nil? }.map { |drv| drv.first }
    end

    def specified_vars(constraint)
      constraint.reject { |rv| rv[1].nil? }
    end


    private

    def convert_to_params(vars)
      vars.inject({}) do |t, var|
        name, value = var
        if value.kind_of?(Array)
          t.merge({ name => { "$in" => value } })
        else
          t.merge({ name => value })
        end
      end
    end

  end
end

