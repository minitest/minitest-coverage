require "json"
require "coverage/start"

pwd_re = Regexp.union Dir.pwd
pruner = lambda { |k,_| k !~ pwd_re }

at_exit { # get behind minitest if we're running alongside
  at_exit {
    coverage = Coverage.result.reject(&pruner)

    File.open "coverage.json", "w" do |f|
      f.puts JSON.pretty_generate coverage
    end
  }
}
