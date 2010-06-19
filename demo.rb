#!/usr/bin/ruby

require 'painite'
require 'timer'

@ps = PSpace.new("pspace")
def P(var_expr, *vals)
  @ps.prob(var_expr, *vals)
end

def read_index(file_path)
  File.open(file_path) do |index|
    index.each do |line|
      spam, path = line.split(/\s+/)
      yield spam, File.join(File.dirname(file_path), path)
    end
  end
end

def read_corpus(file_path)
  File.open(file_path) do |file|
    file.each_line do |line|
      line.split(/[^\w\-'$]+/).reject { |token|
        token =~ /^\d+$/ or token.empty?
      }.each do |token|
        yield token
      end
    end
  end
end

def load_corpus(reload = false)
  if Dir.glob("pspace.rbm").empty? or reload == true
    read_index("/Users/iamwil/Datasets/spamds/ham25/other") do |spam, path|
      read_corpus(path) do |word|
        @ps.record("spam" => (spam == "spam") ? true : false, "w" => word.downcase)
      end
      p "read #{path}"
    end
    @ps.save
  else
    @ps.load
  end
end

load_corpus(false)

p "Prob Space has #{@ps.size} records"
puts

# probabilty of spam being true given the word "hello"
Timer::timer(%Q{P("spam | w", true, "yours")}) do
  p "Prob of spam given 'your' #{P("spam | w", true, "your")}"
end
puts

Timer::timer(%Q{P("spam | w", false, "your")}) do
  p "Prob of not spam given 'your' #{P("spam | w", false, "your")}"
end
puts

# see if calculated a posteri
Timer::timer(%Q{P("w | spam", "your", true) * P("spam", true) / P("w", "your")}) do
  p "Calculate a posteri using Bayes #{P("w | spam", "your", true) * P("spam", true) / P("w", "your")}"
end
puts

# probabilty of spam is derived from previous line
Timer::timer(%Q{P("spam | w", true, "penis")}) do
  p "Prob of spam given the word penis: #{P("spam | w", true, "penis")}"
end
puts

# probability of spam being true given the following three words
Timer::timer(%Q{P("spam | w", true, "your", "gas", "viagra")}) do
  prob = ["your", "gas", "viagra"].inject(1) do |t, word|
    t *= P("spam | w", true, word)
  end
  p "Calulate joint probability ass. indep #{prob.inspect}"

  prob = P("spam | w", true, %w(your gas viagra))
  p "Calculate joint probability in one line #{prob.inspect}" 
end
puts

# probability of spam given the three words using a priori
Timer::timer(%Q{P("spam | doc") = P("doc | spam") * P("spam") / P("doc")}) do
  p_doc_spam = ["your", "gas", "viagra"].inject(1) do |t, word|
    t *= P("w | spam", word, true)
  end
  puts %Q{P("doc | spam", ["your", "gas", "viagra"], true) with multiply = #{p_doc_spam}}

  p_spam = P("spam", true)
  puts %Q{P("spam", true) = #{p_spam}}
  
  p_doc = P("w", "your", "gas", "viagra")
  puts %Q{P("doc") = #{p_doc}}

  p "Bayesian probability: #{p_doc_spam * p_spam / p_doc}"
end
puts
