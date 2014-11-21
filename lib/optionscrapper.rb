#
#   Author: Rohith
#   Date: 2014-05-22 23:55:29 +0100 (Thu, 22 May 2014)
#
#  vim:ts=2:sw=2:et
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'optparse'

module OptionScrapper
  ROOT = File.expand_path File.dirname __FILE__

  autoload :Version, "#{ROOT}/optionscrapper/version"
  autoload :OptionsParser,  "#{ROOT}/optionscrapper/optionsparser"

  def self.version
    OptionScrapper::VERSION
  end

  def self.new
    OptionScrapper::OptionsParser::new do |x|
      yield x if block_given?
    end
  end
end
