require "coverage/start"
require "minitest/autorun"
require "minitest/coverage"

module TestMinitest; end

class TestMinitest::TestCoverage < Minitest::Test
  # def cover path
  #   spawn(RbConfig.ruby,
  #         "-Ilib",
  #         "-rcoverage/start",
  #         path,
  #         "--coverage"
  #         # , :out=>"/dev/null"
  #        )
  # end
  #
  # def test_sanity
  #   cover "example.rb"
  # end
end
