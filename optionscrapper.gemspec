#!/usr/bin/env ruby
#
#   Author: Rohith
#   Date: 2014-06-06 16:48:00 +0100 (Thu, 06 Jun 2014)
#
#  vim:ts=2:sw=2:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','lib/optionscrapper' )
require 'version'

Gem::Specification.new do |s|
  s.name        = 'optionscrapper'
  s.version     = OptionScrapper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2014-05-22'
  s.authors     = ['Rohith Jayawardene']
  s.email       = 'gambol99@gmail.com'
  s.homepage    = 'https://github.com/gambol99/optionscrapper'
  s.summary     = %q{Options Parser with subcommand supports}
  s.description = %q{Is a wrapper for optparse which allows for using subcommand more easily}
  s.license     = 'GPL'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
