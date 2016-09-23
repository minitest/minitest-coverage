require "minitest/autorun"
require "example"

class TestExample < Minitest::Test
  def test_y
    assert_equal 42, Example.new.y
  end
end

class TestIncidentalCoverage < Minitest::Test
  def test_y
    assert_equal 42, IncidentalCoverage.new.x
  end
end
