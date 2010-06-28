$: << "lib"

require 'forwardable'
require 'override_methods'

require 'painite/base_engine'
require 'painite/hash_engine'
require 'painite/mongo_engine'

class PSpace
  extend Forwardable
  
  def initialize(name = "prob_space", engine = :hash)
    @evidence = Evidence.const_get("#{engine.to_s.capitalize}Engine").new(name)
  end

  def_delegator :@evidence, :record
  def_delegator :@evidence, :clear
  def_delegator :@evidence, :size
  def_delegator :@evidence, :load
  def_delegator :@evidence, :save
  
  # takes single values
  #
  #   P("spam", true)
  #   P("word", "panther")
  #
  # Also takes given values
  #
  #   P("spam | word", true, "fanboy")
  #
  # Assumes independence for joint probabilities
  #
  #   P("spam, word", [true, "fanboy"])
  #
  # Doesn't yet do joint conditional probabilities
  def prob(var_expr, *vals)
    randvars, condvars = parse(var_expr, *vals)
    
    denominator = @evidence.count_by(condvars)
    numerator = @evidence.count_by(randvars, condvars)
    
    if (numerator == 0 || denominator == 0)
      return additive_smoothing(randvars, condvars).tap { |r|
        puts ["#{randvars.inspect} | #{condvars.inspect}:",
              "#{r[1]} / #{r[2]} = #{r[0]}"].join(" ")
      }[0]
    else
      return (numerator.to_f / denominator.to_f).tap { |r|
        puts ["#{randvars.inspect} | #{condvars.inspect}:",
              "#{numerator} / #{denominator} = #{r}"].join(" ")
      }
    end
  end

  private

  def additive_smoothing(randvars, condvars)
    print "smoothing: "
    cond_count = @evidence.count_by(condvars)
    
    rand_count = (cond_count == 0) ? @evidence.count_by(randvars) : @evidence.count_by(randvars, condvars)
    numerator = (rand_count == 0) ? 1 : rand_count
    denominator = ((cond_count == 0) ? @evidence.size : @evidence.count_by(condvars)) + numerator
    
    return numerator.to_f / denominator.to_f, numerator, denominator
  end
  
  # returns in form:
  #  [[:randvar, rand_val], ...], [[:given_var, given_val], ...]
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

