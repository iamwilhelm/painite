require 'rubygems'
require 'couchrest'

require 'URI'

module Evidence

  module Views
    def view_hash(name, map_func_hash, reduce_func_hash)
      { name.to_sym => map_func_hash.merge(reduce_func_hash) }
    end

    def map
      { :map => "function(doc) { #{yield} };" }
    end

    def reduce
      { :reduce => "function(keys, values) { #{yield} };" }
    end

    def create_view(name, *view_hashes)
      @db.save_doc({ "_id" => "_design/#{name}",
                     :views => view_hashes.inject({}) do |total, view|
                       total.merge(view)
                     end
                   })
    end
    
    def records_view_hash
      view_hash("records",
                map { "emit(null, doc);" },
                reduce { "return values.length;" })
    end
  end
  
  class CouchEngine < BaseEngine
    include Views
    
    def initialize(name, host = "http://localhost:5984/")
      super(name)
      @host = host
      @db = CouchRest.database!(URI.join(@host, @name).to_s)
      
      create_view("pspace", records_view_hash) rescue RestClient::Conflict
    end
    
    def size
      @db.view('pspace/records')["rows"].first["value"]
    end

    # takes a hash of the evidence record
    def record(record)
      @db.save_doc(record)
    end

    def find_by(*constraint_set)
      @db.view('pspace/records', :reduce => false)["rows"]
    end

    # clears the evidence
    def clear
      
    end
      
    def save(filepath = nil)
      puts "No need to save using CouchDb Engine"
      return true
    end

    def load(filepath = nil)
      puts "Nothing to load using CouchDb Engine"
      return false
    end

  end
  
end

if __FILE__ == $0
  require 'pp'
  
  @evidence = Evidence::CouchEngine.new("painite")
  # @evidence.record(:spam => false, :doc => "memo", :word => "hello")
  # @evidence.record(:spam => false, :doc => "memo", :word => "my")
  # @evidence.record(:spam => false, :doc => "memo", :word => "newton")
  # @evidence.record(:spam => true, :doc => "memo", :word => "friend")

  pp @evidence.size
  pp @evidence.find_by
end
