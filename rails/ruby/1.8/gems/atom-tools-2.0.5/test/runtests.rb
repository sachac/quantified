#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")

require "test/unit"

Dir["test_*.rb"].each do |test|
  begin
    require test
  rescue LoadError
    puts "skipping #{test} (LoadError)"
    next
  end
end
