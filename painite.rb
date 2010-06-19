$: << "lib"

require 'forwardable'
require 'override_methods'

require 'painite/base_engine'
require 'painite/hash_engine'


class PSpace
  extend Forwardable
  
  attr_reader :evidence

  def initialize(name = "prob_space", engine = "hash")
    @evidence = Evidence::HashEngine.new(name)
  end

  def_delegator :evidence, :record
  
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
    return indep_joint_prob(randvars) if numerator == 0

    return (denominator == 0) ? 0 : numerator / denominator
  end

  private

  # if we can't find anything, we assume indepencence and
  # multiply the prob of individual values
  def indep_joint_prob(randvars)
    randvars.inject(1) do |t, randvar|
      # to avoid infinite loops
      if @evidence.find_by(randvar).empty? and randvars.length == 1
        t *= 1e-10 # assume a small probability so it's not zero
      else
        t *= prob(*randvar)
      end
    end
  end

  # returns in form:
  #  [[:randvar, rand_val], ...], [[:given_var, given_val], ...]]
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

