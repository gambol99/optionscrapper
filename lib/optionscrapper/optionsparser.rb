#
#   Author: Rohith Jayawardene
#   Email: (gambol99@gmail.com)
#   Date: 2014-05-22 23:55:29 +0100 (Thu, 22 May 2014)
#
#  vim:ts=2:sw=2:et
#
$:.unshift File.join(File.dirname(__FILE__),'.')
require 'misc/utils'
require 'forwardable'
require 'parser'
require 'batch'

module OptionScrapper
  class OptionsParser
      extend Forwardable
    include OptionScrapper::Utils
    GLOBAL_PARSER        = :global
    GLOBAL_OPTION_REGEX  = /^(-[-]?[[:alpha:]-]+)/

    attr_accessor :parsers
    def_delegator :@cursor,  :on

    def initialize
      @cursor  = nil
      @parsers = {}
      # step: create the global parser
      create_parser(GLOBAL_PARSER,'the global parser')
      @cursor.parser.program_name = prog_name
      # step: inject a default help options for global
      @cursor.parser.on( '-h', '--help', 'display this usage menu' ) do
        puts print_usage
        exit 0
      end
      yield self if block_given?
    end

    def command(name, description)
      parser = create_parser(name,description)
      yield parser if block_given?
      parser
    end

    def banner=(value)
      @cursor.parser.banner = offset << value
    end

    def parse!(arguments = ARGV)
      # step: we need to separate into subcommand arguments
      batch_arguments(arguments) do |batch|
        # step: iterate the batches and fire off the parsers for each subcommand
        batch.batches do |name,options|
          parsers[name].parse! options
        end
      end
    end

    def on_command &block
      @cursor.on_command = block
    end

    def usage(message = nil, name = GLOBAL_PARSER)
      # step: if the parser is specified, print only that one
      unless name == GLOBAL_PARSER
        puts parsers[parser_name].print_usage
      else
        # step: else we generate the full parse usage menu
        newline
        puts global_parser.parser
        newline
        # step: we don't need to do this if there are no sub commands
        if parsers.size > 1
          puts offset << "commands : #{horizontal_line(62,'-')}"
          parsers.values.each do |parser|
            next if parser.name == GLOBAL_PARSER
            command_line = parser.name.to_s
            command_line << '(%s)' % [ parser.aliases.join(',') ] unless parser.aliases.empty?
            puts offset  << '%-32s %s' % [ command_line, parser.description ]
          end
          puts offset << horizontal_line(72,'-')
          newline
          parsers.values.each do |parser|
            # step: skip the global, we have already displayed it
            next if parser.name == GLOBAL_PARSER
            # step: we don't need to show this if the subcommand has no options / switches
            next if parser.switches.empty?
            # step: else we can show the parser usage
            puts parser.parser
            newline
          end
        end
      end
      fail message if message
      newline
      exit 0
    end
    alias_method :print_usage, :usage

    def method_missing(method, *args, &block)
      if @cursor.respond_to? method
        @cursor.send method, args, &block if args and !args.empty?
        @cursor.send method, &block if !args or args.empty?
      elsif @cursor.parser.respond_to? method
        @cursor.parser.send method, args, &block if args and !args.empty?
        @cursor.parser.send method, &block if !args or args.empty?
      else
        super(method, args, block)
      end
    end

    private
    def create_parser(name,description)
      # step: create a new parser and add to hash collection
      parsers[name] = Parser.new(name,description)
      # step: update the cursor to the newly created parser
      @cursor = parsers[name]
      # step: create a usage for this command
      @cursor.parser.banner = "    #{name} : description: #{description}"
      @cursor.parser.separator "    #{horizontal_line(72)}"
      @cursor.parser.separator ''
      # step: return the parser
      parsers[name]
    end

    # batch: takes the command line options, iterates the options and places them into
    # the correct batch
    def batch_arguments(arguments)
      batch = Batch.new do |x|
        arguments.each do |argument|
          # step: is the argument a subcommand?
          if subcommand?(argument)
            parser = subcommand(argument)
            # step: get the command and set the cursor to the parser
            x.cursor = parser.name
            # step: call the on_command block
            parser.on_command.call
          else
            # step: is this argument a parser argument
            parser = subcommand(x.cursor)
            if !is_switch?(argument)
              if x.previous
                x.global(argument)
              else
                x.add argument
              end
            elsif !parser.switch?(argument) and global_parser.switch?(argument)
              x.global(argument)
              x.previous = x.cursor
            else
              x.add argument
            end
          end
        end
      end
      yield batch if block_given?
      batch
    end

    def subcommand?(name)
      name = symbolize!(name)
      return ( parsers.has_key?(name) or alias?(name) ) ? true : false
    end

    def subcommand(name)
      name = symbolize!(name)
      raise StandardError, "subcommand: parser: #{name} does not exists" unless subcommand? name
      unless parsers[name]
        # step: it must be an alias
        name = parsers.values.select { |parser|
          parser.aliases.include? name
        }.first.name
      end
      parsers[name]
    end

    def alias?(name)
      name = symbolize!(name)
      parsers.values.each do |parser|
        next if parser.name == GLOBAL_PARSER
        next if parser.aliases.empty?
        return true if parser.aliases.include? name
      end
      false
    end

    def is_switch?(argument)
      argument =~ GLOBAL_OPTION_REGEX
    end

    def global_parser
      subcommand(GLOBAL_PARSER)
    end

    def prog_name
      File.basename($0)
    end

    def symbolize!(name)
      ( name.is_a? Symbol ) ? name : name.to_sym
    end
  end
end
