#!/usr/bin/ruby

require 'painite'

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
        P.record("spam" => (spam == "spam") ? true : false, "w" => word.downcase)
        p word if word == "your"
      end
      p "read #{path}"
    end
    P.save
  else
    P.load
  end
end

load_corpus

# probabilty of spam being true given the word "hello"
p "Prob of spam given 'your' #{P("spam | w", true, "your")}"
p "Prob of not spam given 'your' #{P("spam | w", false, "your")}"

# see if calculated a posteri
p "Calculate a posteri using Bayes #{P("w | spam", "your", true) * P("spam", true) / P("w", "your")}"

# probability of spam being true given the
prob = ["your", "gas", "viagra"].inject(1) do |t, word|
  wordprob = P("spam | w", true, word)
  t *= wordprob
end
p "Calulate joint probability ass. indep #{prob.inspect}"

# probabilty of P("spam", true)
P("w | spam", true, text) * P("spam", true) / P("w", text)

# # probabilty of spam is derived from previous line
# P("spam | w", true, "penis")
