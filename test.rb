require 'test/unit'
require "painite"

class PainiteTest < Test::Unit::TestCase

  def setup
    @ps = PSpace.new
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

  def P(var_expr, *vals)
    @ps.prob(var_expr, *vals)
  end

  def test_single_variable
    assert_equal(0.7, P("spam", true))
    assert(0.001 >= P("doc", "albacore"))
  end

  def test_joint_variable
    assert(0.001 >= P("spam, w", true, "hoof"), "hoof failed")
    assert_equal(1.0 / 10, P("doc, w", "tuna", "hello"), "doc failed")
    assert_equal(2.0 / 10, P("spam, w", true, "hello"), "hello failed")
  end

  def test_independence
    assert_equal(P("spam", false) * P("w", "viagra"), P("spam, w", false, "viagra"))
    assert_equal(P("spam", true) * P("w", "lover"), P("spam, w", true, "lover"))
    assert_equal(P("doc", "salmon") * P("w", "hello"), P("doc, w", "salmon", "hello"))
    assert_equal(P("w", "lover") * P("w", "penis"), P("w, w", "lover", "penis"))
  end
  
  def test_multiple_values_variable
    assert_equal(0.5, P("w", ["hello", "penis"]))
    assert_equal(0.125, P("w | doc", "penis", ["salmon", "tuna"]))
  end

  def test_conditional_variable
    assert_equal(2.0 / 3.0, P("spam | w", true, "hello"))
    assert_equal(2.0 / 3.0, P("w | spam", "hello", true) * P("spam", true) / P("w", "hello"))
  end

  def test_conditional_joint_variable
    assert_equal(0.5, P("spam | w, doc", true, "hello", "salmon"))
  end

  def test_joint_conditional_variable
    assert_equal(0.2, P("spam, w | doc", true, "hello", "salmon"))
    assert_equal(0.2, P("w, spam | doc", "hello", true, "salmon"))
  end
end
