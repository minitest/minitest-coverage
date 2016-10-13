require "minitest/autorun"
require "example"

class TestExample < Minitest::Test
  def test_y
    assert_equal 42, Example.new.y
  end
end
