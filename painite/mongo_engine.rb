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
      puts "cleared the collection"
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

    def save(filepath = nil)
      puts "Mongo doesn't need to save the database"
    end

    def load(filepath = nil)
      puts "Mongo doesn't need to load the database"
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

