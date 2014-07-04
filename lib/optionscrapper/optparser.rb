#
#   Author: Rohith
#   Date: 2014-05-22 23:55:29 +0100 (Thu, 22 May 2014)
#
#  vim:ts=2:sw=2:et
#
module OptionScrapper
class OptParser 
  attr_reader :parsers
  
  def initialize &block 
    @parsers = initialize_parsers
    yield self if block_given?
  end

  def parse! arguments = ARGV
    # step: we need to separate into subcommand arguments
    batches  = batch_arguments arguments, @parsers
    # step: iterate the batches and fire off the parsers for each subcommand
    batches.each_pair { |cmd,args| @parsers[cmd][:parser].parse! args }
  end

  def command name, desc, &block 
    # step: create a new command parser
    label   = name.to_sym
    parser  = {
      :name         => label,
      :description  => desc,
      :parser       => ::OptionParser::new
    } 
    # step: add a spacer to the current one
    @cursor[:parser].separator ""
    # step: add the new parser to the @parsers
    @parsers[label] = parser
    # step: update the cursor to the new parser
    @cursor         = parser
    # step: create a useage for this command 
    @cursor[:parser].banner = "    %s : desc: %s" % [ name, desc ]
    @cursor[:parser].separator "    %s" % [ hline( 72 ) ]
    @cursor[:parser].separator ""
    yield self if block_given?
  end
  
  def on_command &block 
    @cursor[:on_command] = block if block_given?
  end

  def on *args, &block
    @cursor[:parser].on *args do |x| 
      yield x if block_given? 
    end
  end

  def to_s
    print_usage
  end

  def method_missing( method, *args, &block)  
    if @cursor[:parser].respond_to? method 
      case method 
      when :banner=
        @cursor[:parser].send method, args.first, &block 
      else
        @cursor[:parser].send method, args, &block
      end
    else
      super(method, args, block)
    end
  end

  private
  # method: take the command line arguments and batches them into the 
  # perspective subcommand i.e global / sub1 / sub2 etc
  def batch_arguments arguments = ARGV, commands = @parsers
    # step: we iterate the command line arguments - all options are initially placed
    # into the global arguments; when we hit a subcommand we reset the cursor 
    batches = {}
    batches[:global] = []
    # step: set the cursor to the global batch
    cursor = batches[:global]
    arguments.each do |arg|
      # step: is the argument a subcommand?
      if commands.has_key? arg.to_sym
        name = arg.to_sym
        # step: create the new batch, reset the cursor and iterate
        batches[name] = []
        cursor = batches[name]
        # step: call the block if the on_command block is set
        @parsers[name][:on_command].call if @parsers[name].has_key? :on_command
        next
      end
      # step: otherwise we inject into the current batch
      cursor << arg 
    end
    batches
  end

  def initialize_parsers
    # step: initialize our holders
    parsers       = {}
    global_parser = {
      :name   => :global,
      :parser => ::OptionParser::new
    }
    parsers[:global] = global_parser
    # step: set the cursor to global - i.e. all options are initially global
    @cursor = parsers[:global]
    # step: inject a default help options for global
    @cursor[:parser].on( '-h', '--help', 'display this usage menu' ) { print_usage }
    # step: return the parsers
    parsers
  end

  def print_usage
    puts
    puts @parsers[:global][:parser] 
    puts "    commands : %s" % [ hline( 61, "-" ) ] 
    @parsers.each_pair do |name,parser|
      next if name == :global
      puts "    - %-24s : %s" % [ name, parser[:description] ]
    end
    puts "    %s" % [ hline( 72, "-" ) ] 
    unless @parsers.empty?
      @cursor[:parser].separator ""
      puts 
      @parsers.each_pair do |name,parser|
        next if name == :global
        puts parser[:parser]
      end
      exit 0
    end
  end

  def hline length, symbol = '-'
    line = ""
    length.times.each { line << "#{symbol}" }
    line
  end
end
end
