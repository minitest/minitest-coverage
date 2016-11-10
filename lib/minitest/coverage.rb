module Minitest; end

module Minitest
  module CoverageRunner
    VERSION = "1.0.0.b1"

    def self.coverage_baseline
      @@coverage_baseline
    end

    def self.coverage_baseline= o
      @@coverage_baseline = o
    end

    def coverage_baseline
      @@coverage_baseline
    end

    def self.coverage_data
      @@coverage_data
    end

    def self.coverage_data= o
      @@coverage_data = o
    end

    def coverage_data
      @@coverage_data
    end

    # Marshal to unfreeze (frozen state depends on ruby version?)
    self.coverage_baseline = Marshal.load Marshal.dump Coverage.peek_result

    # full dupe of baseline
    self.coverage_data     = Marshal.load Marshal.dump coverage_baseline

    def clean_path path
      path[Dir.pwd.length+1..-1]
    end

    def coverage_diff test_name, new, old
      puts

      path, lines = find_path_and_lines(new, test_name)

      return unless path && lines

      old_lines = old[path] || lines.map { |x| x ? 0 : nil }

      print "  #{clean_path path}"
      a, b, max = pct(old_lines), pct(lines), max(lines)

      if (a - b).abs < 0.01 then
        puts ": no change at %.1f%% of %d lines" % [a, max]
      else
        puts ": from %.1f%% to %.1f%% of %d lines" % [a, b, max]
      end
    end

    PWD = Dir.pwd

    def find_path_and_lines coverage, test_name
      impl_re = /\/#{impl_name test_name}$/

      coverage.sort.find { |path, lines| # sorting biases towards app and lib
        next unless path.start_with? PWD
        path =~ impl_re
      }
    end

    def impl_name test_name
      unless test_name then
        p :nil => [test_name, self.name]
        p caller
        abort
      end
      (test_name[/^([\w:]+?)Test/, 1] || # rails style
       test_name[/^Test([\w:]+)$/, 1] || # ruby style
       test_name).                       # give up
        gsub(/([a-z])([A-Z])/, '\1_\2').
        gsub(/::/, "/").
        downcase + "\\.rb"
    rescue => e
      p e
      p test_name
      p test_name[/^([\w:]+?)Test(?:::)?/, 1]
      raise e
    end

    def max lines
      lines.compact.size
    end

    def merge_coverage new_coverage
      path, lines = find_path_and_lines new_coverage, self.name

      if path and lines then
        coverage_data[path] = lines
      else
        # warn "Bad mapping for #{self.name}. Skipping coverage." # TODO
      end
    end

    def output_coverage
      require "json"

      cleaned = coverage_data.reject { |path, lines|
        path.nil? or
          path.include? RbConfig::CONFIG["libdir"] or
          not path.start_with? PWD
      }

      File.open "coverage.json", "w" do |f|
        f.puts JSON.pretty_generate cleaned
      end

      warn "created coverage.json"
    end

    module_function :output_coverage

    def pct lines
      max = max lines
      n   = max - lines.count(0)
      100.0*n/max
    end

    def run *args
      return if self.runnable_methods.empty?

      unless impl_name self.name then
        warn "BAD NAME: #{self.name} -- can't map to implementation. Skipping"
      end

      puts
      puts "#{self.name}:"

      super

      new_coverage = Coverage.peek_result

      coverage_diff(self.name, new_coverage, coverage_data)
      merge_coverage new_coverage

      if Coverage.respond_to? :result= then
        Coverage.result = coverage_baseline
      else
        @@coverage_warning ||= false
        unless @@coverage_warning then
          warn "Unable to reset coverage baseline. Numbers will be artificially high."
          @@coverage_warning = true
        end
      end
    end
  end
end
