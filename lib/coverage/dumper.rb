require "json"

at_exit { # get behind minitest if we're running alongside
  at_exit {
    coverage = Coverage.result

    File.open "baseline.json", "w" do |f|
      f.puts JSON.pretty_generate coverage
    end
  }
}
