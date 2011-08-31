require 'rubygems'
require 'spec'

$:.unshift 'lib/', File.dirname(__FILE__) + '/../lib'

def fixtures(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}.xml")
end

