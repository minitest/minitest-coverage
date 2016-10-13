require "json"
require "coverage/start"
require "minitest/autorun"
require "minitest/coverage"

module TestMinitest; end

class TestMinitest::TestCoverage < Minitest::Test
  attr_accessor :data

  CPATH = "coverage.json"
  N = nil

  def teardown
    File.unlink CPATH
  end

  def cover *paths
    cmd = [
           RbConfig.ruby,
           "-Ilib",
           "-I../../minitest/dev/lib",
           "-Iexample/lib",
           "bin/minitest_coverage",
           *paths,
           "-v",
           "--seed", "41015",
           "--coverage",
          ]

    Process.wait spawn(*cmd, :out => "/dev/null", :err => "/dev/null")

    assert_operator File, :file?, CPATH
    self.data = JSON.load File.read CPATH
  end

  def path path
    File.join Dir.pwd, path
  end

  def assert_coverage path, exp
    if exp then
      assert_equal exp, data[path(path)]
    else
      assert_nil data[path(path)]
    end
  end

  def test_indirect
    cover "example/test/test_indirect.rb"

    assert_coverage "example/lib/indirect.rb", [1, N, 1, 1, 1, N, N]
    assert_coverage "example/lib/example.rb",  [1, 1, 0, N, N, 1, 0, N, N]
  end

  def test_example
    cover "example/test/test_example.rb"

    assert_coverage "example/lib/indirect.rb", N
    assert_coverage "example/lib/example.rb",  [1, 1, 0, N, N, 1, 1, N, N] # x intentionally not covered
  end

  def test_combined
    cover "example/test/test_example.rb", "example/test/test_indirect.rb"

    assert_coverage "example/lib/indirect.rb", [1, N, 1, 1, 1, N, N]
    assert_coverage "example/lib/example.rb",  [1, 1, 0, N, N, 1, 1, N, N]
  end
end
