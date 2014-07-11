#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-07-11 14:39:16 +0100 (Fri, 11 Jul 2014)
#
#  vim:ts=4:sw=4:et
#
module OptionScrapper
  module Usage
    def usage message = nil, parser_name = :global
      # step: if the parser is specified, print only that one
      if !parser_name == :global
        puts parsers[parser_name][:parser]
      else
        # step: else we generate the full parse usage menu
        puts "\n%s" % [ parsers[:global][:parser] ]
        # step: we don't need to do this if there are no sub commands
        subcommand_usage 
      end
      fail message if message
      newline
      exit 0
    end
    alias_method :print_usage, :usage
    alias_method :to_s, :usage
  
    def subcommand_usage 
      if parsers.size > 1
        puts "    commands : %s" % [ horizontal_line( 61, "-" ) ]
        parsers.each_pair do |name,parsep|
          next if name == :global
          puts "    - %-24s : %s" % [ name, parsep[:description] ]
        end
        puts "    %s" % [ horizontal_line( 72, "-" ) ]
        @cursor[:parser].separator ""
        newline
        parsers.each_pair do |name,parsep|
          next if name == :global
          puts parsep[:parser]
        end
      end
    end

    def fail message
      puts "[error]: " << message
      exit 1
    end

    def horizontal_line length, symbol = '-'
      line = ""
      length.times.each { line << "#{symbol}" }
      line
    end
  end
end


