#
#   Author: Rohith
#   Date: 2014-11-10 21:50:43 +0000 (Mon, 10 Nov 2014)
#
#  vim:ts=2:sw=2:et
#
module OptionScrapper
  class Batch
    attr_accessor :cursor, :previous

    def initialize
      @cursor   = OptionScrapper::OptionsParser::GLOBAL_PARSER
      @batches  = { OptionScrapper::OptionsParser::GLOBAL_PARSER => [] }
      @previous = nil
      yield self if block_given?
    end

    def batches
      raise StandardError, 'batches: you have not supplied a block to call' unless block_given?
      @batches.each_pair do |name,arguments|
        yield name,arguments
      end
    end

    def add(argument)
      @previous           = nil
      @batches[@cursor] ||= []
      @batches[@cursor] << argument
    end

    def global(argument)
      @batches[OptionScrapper::OptionsParser::GLOBAL_PARSER] << argument
    end
  end
end
