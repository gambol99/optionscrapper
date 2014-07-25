#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),'.','../lib')

require 'optionscrapper'
require 'pp'

@options = {
  :verbose    => true,
  :networks   => [],
  :security   => []
}

def parser
  @parser ||= OptionScrapper::new do |o|
    o.on( '-S stack',       '--stack NAME',             'the name of the openstack you wish to connect' ) { |x|   @options[:stack]             = x    }
    o.on( '-c CONFIG',      '--config CONFIG',          'the configuration file to read credentials' )    { |x|   @options[:config]            = x    }
    o.on( nil,              '--dry-run',                'perform a dry run' )                             {       @options[:dry_run]           = true }
    o.on( '-v',             '--verbose',                'switch on verbose mode' )                        {       @options[:verbose]           = true }
    o.command :launch, 'launch a instance in to openstack cluster' do
      o.command_alias :ln
      o.on( '-H HOSTNAME',    '--hostname HOSTNAME',      'the hostname of instance you are creating' )     { |x|   @options[:hostname]          =  x  }
      o.on( '-i IMAGE',       '--image IMAGE',            'the image you wish to boot from' )               { |x|   @options[:image]             =  x  }
      o.on( '-f FLAVOR',      '--flavor FLAVOR',          'the flavor the instance should work from' )      { |x|   @options[:flavor]            =  x  }
      o.on( '-k KEYPAIR',     '--keypair KEYPAIR',        'the keypair the instance should use' )           { |x|   @options[:keypair]           =  x  }
      o.on( '-n NETWORK',     '--network NETWORK',        'the network the instance should be connected' )  { |x|   @options[:networks]          << x  }
      o.on( '-s SECURITY',    '--secgroups SECURITY',     'the security group assigned to the instance' )   { |x|   @options[:security_group]    << x  }
      o.on( '-u USER_DATA',   '--user-data USER_DATA',    'the user data template' )                        { |x|   @options[:user_data]         =  x  }
      o.on( nil,              '--hypervisor HOST',        'the compute node you want the instance to run' ) { |x|   @options[:availability_zone] =  x  }
      o.on( '-e',             '--error',                  'cause an error' )                                { o.usage                                  }
      o.on_command { @options[:action] = :launch   }
    end
    o.command :destroy, 'destroy and delete an instance in openstack' do
      o.command_alias :des
      o.on( '-H HOSTNAME',    '--hostname HOSTNAME',      'the hostname of instance you are creating' )     { |x|   @options[:hostname]          =  x    }
      o.on_command { @options[:action] = :destroy  }
    end
    o.command :snapshot, 'snapshot a instance within openstack' do
      o.command_alias :sp
      o.on( '-H HOSTNAME',    '--hostname HOSTNAME',      'the hostname of the instance being snapshot' )   { |x|   @options[:hostname]          =  x    }
      o.on( '-s NAME',        '--snapshot NAME',          'the name of the snapshot you are creating' )     { |x|   @options[:snapshot]          =  x    }
      o.on( nil,              '--wait',                   'wait on the snapshot to complete' )              { |x|   @options[:wait]              =  true }
      o.on( '-f',             '--force',                  'if the snapshot image exists, delete it' )       { |x|   @options[:force]             =  true }
      o.on_command { @options[:action] = :snapshot }
    end
  end
end

begin
  parser.parse!
  PP.pp @options
rescue SystemExit => e
  exit e.status
rescue Exception => e
  parser.usage e.message
end

