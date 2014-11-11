#
#   Author: Rohith
#   Date: 2014-05-22 23:55:29 +0100 (Thu, 22 May 2014)
#
#  vim:ts=2:sw=2:et
#
$:.unshift File.join(File.dirname(__FILE__),'.','./')
require 'optparse'
require 'optionscrapper/ext/optparse'
require 'optionscrapper/optionsparser'

module OptionScrapper
  ROOT = File.expand_path File.dirname __FILE__

  require "#{ROOT}/optionscrapper/version"

  def self.version
    OptionScrapper::VERSION
  end

  def self.new
    OptionScrapper::OptionsParser::new do |x|
      yield x if block_given?
    end
  end
end
