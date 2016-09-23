require "coverage"
Coverage.start

require "minitest"
require "pp"

module Minitest
  @coverage = false

  def self.plugin_coverage_options opts, options # :nodoc:
    opts.on "-c", "--coverage [BASELINE]", String, "Generate coverage reports." do |s|
      require "coverage/start"
      # TODO: maybe warn about this being too late in the process?

      unless Coverage.respond_to? :peek_result then
        abort "ABORTING: minitest-coverage only works on ruby 2.3+"
      end

      @coverage = s || true
    end
  end

  def self.plugin_coverage_init options # :nodoc:
    if @coverage then
      require "coverage"
      require "minitest/coverage"
      Minitest::Test.singleton_class.prepend Minitest::CoverageRunner

      if String === @coverage then
        require "json"
        Minitest::CoverageRunner.coverage_baseline = JSON.load File.read @coverage
      end

      Minitest.after_run do
        Minitest::CoverageRunner.output_coverage
      end
    end
  end
end
