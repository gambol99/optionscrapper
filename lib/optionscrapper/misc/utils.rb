#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-11-11 11:58:05 +0000 (Tue, 11 Nov 2014)
#
#  vim:ts=2:sw=2:et
#
module OptionScrapper
  module Utils
    alias_method :newline, :puts

    def offset(length = 4, spacer = "")
      length.times.each { spacer << " " }
      spacer
    end

    def fail(message)
      puts "[error]: " << message
      exit 1
    end

    def horizontal_line(length, symbol = '-', line = "")
      length.times.each { line << "#{symbol}" }
      line
    end
  end
end
