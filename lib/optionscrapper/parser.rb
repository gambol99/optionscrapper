#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-11-10 17:30:21 +0000 (Mon, 10 Nov 2014)
#
#  vim:ts=2:sw=2:et
#
module OptionScrapper
  class Parser
    include OptionScrapper::Utils
    attr_reader :name,:description,:parser,:switches,:aliases
    attr_accessor :on_command

    def initialize(name,description)
      @name         = name.to_sym
      @description  = description
      @switches     = {}
      @aliases      = []
      @parser       = ::OptionParser.new
      @on_command   = Proc::new {}
    end

    # alias: a subcommand alias
    def alias(name); aliases << name.first; end

    #
    # on: is the standard means of adding a command line option to the parser. The method
    # excepts OptParser format extracts some information for meta data reasons and passes the
    # call down the OptParser lib
    #
    def on(*args)
      # step: we use this entry point to build of a list of switches
      parse_option_switches(*args) do |option_name|
        switches[option_name] = true
      end
      # step: pass the request to the underlining gem
      parser.on(*args) do |x|
        yield x if block_given?
      end
    end

    def parse!(arguments)
      parser.parse!(arguments)
    end

    def switch? argument;
      switches.has_key? argument
    end

    def alias? argument
      aliases.include? argument
    end

    # --- Method Aliases ---
    alias_method :command_alias, :alias
    #alias_method :print_usage, :usage
    #alias_method :to_s, :usage

    private
    def method_missing(method, *args, &block)
      if parser.respond_to? method
        case method
          when :banner=
            parser.send method, args.first, &block
          else
            parser.send method, args, &block if args and !args.empty?
            parser.send method, &block if !args or args.empty?
        end
      else
        super(method, args, block)
      end
    end

    def parse_option_switches(*args)
      if args and args.size >= 2
        args[0..1].each do |a|
          if a =~ OptionScrapper::OptionsParser::GLOBAL_OPTION_REGEX
            yield $1
          end
        end
      end
    end
  end
end
