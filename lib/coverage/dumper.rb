require "json"
require "coverage/start"

at_exit { # get behind minitest if we're running alongside
  at_exit {
    coverage = Coverage.result

    File.open "coverage.json", "w" do |f|
      f.puts JSON.pretty_generate coverage
    end
  }
}
