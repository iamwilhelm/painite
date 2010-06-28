#!/usr/bin/ruby

require 'painite'
require 'timer'

@ps = PSpace.new("pspace", "mongo")
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
  times = []
  if Dir.glob("pspace.rbm").empty? or reload == true
    @ps.clear
    read_index("/Users/iamwil/Datasets/spamds/ham25/other") do |spam, path|
      read_corpus(path) do |word|
        times << Timer::timer() do
          @ps.record("spam" => (spam == "spam") ? true : false, "w" => word.downcase)
        end
      end
      p "read #{path}"
    end
    @ps.save
    total_time = times.inject { |t,e| t += e }
    ave_time = total_time / times.size
    puts "Total inserts: #{times.size}"
    puts "Total time (s): #{total_time}"
    puts "Average time per insertion: #{ave_time}"
    puts "Insertions per second: #{ 1 / ave_time }"
  else
    @ps.load
  end
end

load_corpus(false)

p "Prob Space has #{@ps.size} records"
puts

# # probabilty of spam being true given the word "yours"
# Timer::timer(%Q{P("spam | w", true, "yours")}) do
#   p "Prob of spam given 'your': #{P("spam | w", true, "your")}"
# end
# puts

# # see if calculated a posteri by multiplication
# Timer::timer(%Q{P("w | spam", "your", true) * P("spam", true) / P("w", "your")}) do
#   p "Prob of not spam given 'your' using Bayes Rule: #{P("w | spam", "your", true) * P("spam", true) / P("w", "your")}"
# end
# p "The previous two tests should be equal"
# puts

# Timer::timer(%Q{P("spam | w", false, "your")}) do
#   p "Prob of not spam given 'your': #{P("spam | w", false, "your")}"
# end
# puts

Timer::timer(%Q{P("spam, w", true, ["that", "the"])}) do
  prob1 = P("spam, w", true, %w(the that))
  p "Calculate joint probability in one line: #{prob1.inspect}"
  prob2 = P("spam | w", true, %w(the that)) * P("w", %w(the that))
  p "Calculate joint probability w/ multiply: #{prob2.inspect}"
  p "Equal? #{prob1 == prob2}"
end
puts

Timer::timer(%Q{P("spam | w", true, ["your", "viagra"])}) do
  prob1 = P("spam | w", true, %w(your viagra))
  p "Calculate joint conditional probability in one line: #{prob1.inspect}"
  prob2 = P("spam, w", true, %w(your viagra)) / P("w", %w(your viagra))
  p "Calculate joint probability with division: #{prob2.inspect}"
  p "Equal? #{prob1 == prob2}"
end
puts

Timer::timer(%Q{P("spam, w", true, ["your", "viagra"])}) do
  prob1 = P("spam, w", true, ["your", "viagra"])
  p "Joint probability in one line: #{prob1}"
  prob2 = P("spam | w", true, ["your", "viagra"]) * P("w", ["your", "viagra"])
  p "Joint probability in expanded in multiplication: #{prob2}"
  prob3 = P("spam | w", true, ["your", "viagra"]) * P("w | w", "your", "viagra") * P("w", "viagra")
  p "Joint probability in expanded in multiplication: #{prob3}"

  p "Equal? #{prob1 == prob2}"
  p "Equal? #{prob2 == prob3}"
end
puts

Timer::timer(%Q{P("w", ["your", "viagra"])}) do
  prob1 = P("w", "your")
  p "Joint probability in for 'your': #{prob1}"
  prob2 = P("w", "viagra")
  p "Joint probability in for 'viagra': #{prob2}"
  prob3 = P("w", ["your", "viagra"])
  p "Joint probability in expanded in multiplication: #{prob3}"
  prob4 = P("w | w", "your", "viagra") * P("w", "viagra")
  p "Joint probability in expanded in multiplication: #{prob4}"

  p "Equal? #{prob1 == prob2}"
end
puts


puts "----------------------"

Timer::timer(%Q{P(spam, [your, viagra]) / P([your, viagra])}) do
  num = P("w | w, spam", "your", "viagra", true) * P("w | spam", "viagra", true) * P("spam", true)
  den = P("w | w, spam", "your", "viagra", true) * P("w | spam", "viagra", true) * P("spam", true) +
    P("w | w, spam", "your", "viagra", false) * P("w | spam", "viagra", false) * P("spam", false)
  prob = num / den
  p "Calculate joint probability with division: #{prob.inspect}"
end
puts
p "The previous three lines should be equal"
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
