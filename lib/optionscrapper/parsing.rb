#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-11 14:26:25 +0100 (Fri, 11 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
module OptionScrapper
  module Parsing
    OptionRegex = /^(-[-]?[[:alpha:]-]+)/

    private
    # [ -c config launch -H rohith -i djskdjs -n 2 -f dksldkslkdsldksl --stack hq --dry-run -f mine ]
    # [ -c config launch -H rohith -i djskdjs -n 2 -f dksldkslkdsldksl --dry-run -S hq ]
    def batch_arguments arguments = ARGV, commands = parsers
      # step: create the batches
      batches  = { :global => [] }
      current  = :global
      previous = nil

      arguments.each do |argument|
        # step: is the argument a subcommand?
        if command? argument
          #puts "SUBCOMMAND: #{argument}"
          current  = command_name argument
          previous = nil
          # step: create the new batch, reset the cursor and iterate
          batches[current] = []
          # step: call the block if the on_command block is set
          parsers[current][:on_command].call if parsers[current].has_key? :on_command
        else
          unless option? argument
            batches[current] << argument; next
          end
          # else we are processing a command line option and we are in global
          if previous
            current  = previous
            previous = nil
          end

          if !parser_option?( current, argument ) and global_option? argument
            previous = current
            current  = :global
            batches[current] << argument
          else
            # step: otherwise we inject into the current batch
            batches[current] << argument
          end
        end
      end
      batches
    end

    def parser name, description = nil
      p = {
        :name     => name.to_sym,
        :parser   => ::OptionParser::new,
        :switches => {},
      }
      p[:description] = description if description
      p
    end

    def command? argument
      parsers.has_key? argument.to_sym
    end

    def command_name argument
      argument.to_sym
    end

    def parsers
      @parsers ||= {}
    end

    def option? argument
      argument =~ OptionRegex
    end

    def parser_option? parser_name, option
      parsers[parser_name][:switches].has_key? option
    end

    def global_parser
      parsers[:global][:parser]
    end

    def global_switches
      parsers[:global][:switches]
    end

    def global_option? option
      global_switches.has_key? option
    end

    def parse_option_switches *args, &block
      if args and args.size >= 2
        args[0..1].each do |a|
          yield $1 if a =~ OptionRegex and block_given?
        end
      end
    end
  end
end
