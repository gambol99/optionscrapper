#
#   Author: Rohith
#   Date: 2014-05-22 23:55:29 +0100 (Thu, 22 May 2014)
#
#  vim:ts=2:sw=2:et
#
$:.unshift File.join(File.dirname(__FILE__),'.')
require 'parsing'
require 'usage'

module OptionScrapper
  class OptParser
    include OptionScrapper::Parsing
    include OptionScrapper::Usage

    alias_method :newline, :puts

    def initialize &block
      initialize_parsers
      yield self if block_given?
    end

    def parse! arguments = ARGV
      # step: we need to separate into subcommand arguments
      batches  = batch_arguments arguments, parsers
      # step: iterate the batches and fire off the parsers for each subcommand
      batches.each_pair { |cmd,args| parsers[cmd][:parser].parse! args }
    end

    def command name, description, &block
      # step: create a new command parser
      command_name = name.to_sym
      # step: create a new command parser
      p = parser( command_name, description )
      # step: add a spacer to the current one
      @cursor[:parser].separator ""
      # step: add the new parser to the @parsers
      parsers[command_name] = p
      # step: update the cursor to the new parser
      @cursor = p
      # step: create a useage for this command
      @cursor[:parser].banner = "    %s : description: %s" % [ name, description ]
      @cursor[:parser].separator "    %s" % [ horizontal_line( 72 ) ]
      @cursor[:parser].separator ""
      yield @cursor[:parser] if block_given?
    end

    def on_command &block
      @cursor[:on_command] = block if block_given?
    end

    def on *args, &block
      # step: we are creating an array of all the
      parse_option_switches *args do |x|
        @cursor[:switches][x] = true
      end
      @cursor[:parser].on *args do |x|
        # step: build up a list of switches for this command
        yield x if block_given?
      end
    end

    private
    def method_missing method, *args, &block
      if @cursor[:parser].respond_to? method
        case method
        when :banner=
          @cursor[:parser].send method, args.first, &block
        else
          @cursor[:parser].send method, args, &block if args and !args.empty?
          @cursor[:parser].send method, &block if !args or args.empty?
        end
      else
        super( method, args, block )
      end
    end

    def initialize_parsers
      # step: we create the global and inject the global parser into the parser hash
      parsers[:global] = parser( 'global' )
      parsers[:global][:parser].program_name = program_name
      # step: set the cursor to global - i.e. all options are initially global
      @cursor = parsers[:global]
      # step: inject a default help options for global
      @cursor[:parser].on( '-h', '--help', 'display this usage menu' ) do
        puts print_usage
        exit 0
      end
    end
  end
end
