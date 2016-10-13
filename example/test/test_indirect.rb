require "minitest/autorun"
require "indirect"

class TestIndirect < Minitest::Test
  def test_y
    assert_equal 42, Indirect.new.x
  end
end
