require 'test/unit'
require "painite"

class PainiteTest < Test::Unit::TestCase

  def setup
    @ps = PSpace.setup(:engine => :mongo)

    @ps.clear
    
    @ps.record(:spam => false, "w" => "hello", "doc" => "salmon")
    @ps.record(:spam => true, "w" => "hello", "doc" => "salmon")
    @ps.record(:spam => true, "w" => "penis", "doc" => "salmon")
    @ps.record(:spam => false, "w" => "lover", "doc" => "salmon")
    @ps.record(:spam => true, "w" => "lover", "doc" => "salmon")
    @ps.record(:spam => true, "w" => "viagra", "doc" => "tuna")
    @ps.record(:spam => true, "w" => "hello", "doc" => "tuna")
    @ps.record(:spam => true, "w" => "increase", "doc" => "tuna")
    @ps.record(:spam => false, "w" => "table", "doc" => "bass")
    @ps.record(:spam => true, "w" => "penis", "doc" => "bass")
  end

  ###
  
  def test_single_variable
    assert_equal(0.7, P("spam", true))
    assert_equal(0.3, P("w", "hello"))
  end

  def test_single_variable_smoothing
    assert_equal(1.0 / 11, P("doc", "no exist"))
  end
  
  def test_single_variable_distribution
    distr = { ["salmon"] => 5, ["tuna"] => 3, ["bass"] => 2 }
    assert_equal(distr, P("doc"))
  end

  ###
  
  def test_different_joint_variable
    assert_equal(1.0 / 10, P("doc, w", "tuna", "hello"), "doc failed")
    assert_equal(2.0 / 10, P("spam, w", true, "hello"), "hello failed")
  end

  def test_different_joint_variable_smoothing_rand
    assert_equal(1.0 / 11, P("spam, w", true, "no exist"), "hoof failed")
  end
  
  def test_different_joint_variable_transitive
    assert_equal(P("doc, w", "tuna", "hello"), P("w, doc", "hello", "tuna"), "doc failed")
  end

  def test_different_joint_variable_single_distribution
    distr = { ["hello"] => 2, ["penis"] => 1, ["lover"] => 2 }
    assert_equal(distr, P("doc, w", "salmon", nil))
    assert_equal(distr, P("w, doc", nil, "salmon"))
  end

  def test_different_joint_variable_multi_distribution
    distr = {
      ["salmon", "hello"] => 2,
      ["salmon", "penis"] => 1,
      ["salmon", "lover"] => 2,
      ["tuna", "viagra"] => 1,
      ["tuna", "hello"] => 1,
      ["tuna", "increase"] => 1,
      ["bass", "table"] => 1,
      ["bass", "penis"] => 1
    }
    assert_equal(distr, P("doc, w"))
  end
  
  ###
  
  def test_conditional_variable
    assert_equal(2.0 / 3.0, P("spam | w", true, "hello"))
    assert_equal(2.0 / 5.0, P("w | doc", "hello", "salmon"))
  end

  def test_conditional_variable_smoothing_rand
    assert_equal(1.0 / 6, P("w | doc", "no exist", "salmon"))
  end

  def test_conditional_variable_smoothing_cond
    assert_equal(3.0 / 13, P("w | doc", "hello", "no exist"))
  end

  ###
  
  def test_joint_variable_with_conditional
    assert_equal(1.0 / 7, P("w, doc | spam", "hello", "salmon", true))
  end

  def test_joint_variable_with_conditional_smoothing_rand
    assert_equal(1.0 / 8, P("w, doc | spam", "no exist", "no exist", true))
    assert_equal(1.0 / 8, P("w, doc | spam", "no exist", "hello", true))
  end

  def test_joint_variable_with_conditional_smoothing_cond
    assert_equal(2.0 / 12, P("w, doc | spam", "hello", "salmon", "no exist"))
  end

  ###
  
  def test_conditional_joint_variable
    assert_equal(1.0 / 2, P("spam | w, doc", true, "hello", "salmon"))
  end

  def test_conditional_joint_variable_smoothing_rand
    assert_equal(1.0 / 3, P("spam | w, doc", "no exist", "hello", "salmon"))
  end

  def test_conditional_joint_variable_smoothing_cond
    assert_equal(7.0 / 17, P("spam | w, doc", true, "no exist", "salmon"))
  end
  
  # def test_multiple_values_variable
  #   assert_equal(0.5, P("w", ["hello", "penis"]))
  #   assert_equal(0.125, P("w | doc", "penis", ["salmon", "tuna"]))
  # end


  # def test_bayes_rule
  #   assert_equal(P("spam | w", true, "hello"), P("w | spam", "hello", true) * P("spam", true) / P("w", "hello"))
  # end

  # def test_independence
  #   #assert_equal(P("spam", false) * P("w", "viagra"), P("spam, w", false, "viagra"))
  #   assert_equal(P("spam", true) * P("w", "lover"), P("spam, w", true, "lover"))
  #   #assert_equal(P("doc", "salmon") * P("w", "hello"), P("doc, w", "salmon", "hello"))
  #   #assert_equal(P("w", "lover") * P("w", "penis"), P("w, w", "lover", "penis"))
  # end
  
end
