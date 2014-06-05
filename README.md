Options Scrapper!
----------------

Is a wrapper for the OptionsParser (optparse) gem which makes using subcommand like cli easier to define. Note, all the options configuration is passed directly to optparse; so anything it supports, this will support; any methods missing is also passed down to optpasr i.e. banner, separator etc
    
    require 'optionscrapper'
    require 'pp'
    
    @options = {
      :config           => '../config/openstack.yaml',
      :flavor           => '2cores-4096mem-10gb',
      :image            => 'centos-base-6.5-min-stable',
      :user_data        => '../config/user_data.erb',
      :keypair          => 'default',
      :networks         => [],
      :security_group   => [ 'default' ],
      :verbose          => true,
      :force            => false
    }
    
    begin
    
      Parser = OptionScrapper::new do |o|
        o.on( '-S stack',       '--stack NAME',             'the name of the openstack you wish to connect' ) { |x|   @options[:stack]             =  x    }
        o.on( '-c CONFIG',      '--config CONFIG',          'the configuration file to read credentials' )    { |x|   @options[:config]            =  x    }
        o.on( '-v',             '--verbose',                'switch on verbose mode' )                        {       @options[:verbose]           =  true }
        o.command :launch, 'launch a instance in to openstack cluster' do 
          o.on( '-H HOSTNAME',    '--hostname HOSTNAME',      'the hostname of instance you are creating' )     { |x|   @options[:hostname]          =  x    }
          o.on( '-i IMAGE',       '--image IMAGE',            'the image you wish to boot from' )               { |x|   @options[:image]             =  x    }
          o.on( '-f FLAVOR',      '--flavor FLAVOR',          'the flavor the instance should work from' )      { |x|   @options[:flavor]            =  x    }
          o.on( '-k KEYPAIR',     '--keypair KEYPAIR',        'the keypair the instance should use' )           { |x|   @options[:keypair]           =  x    }
          o.on( '-n NETWORK',     '--network NETWORK',        'the network the instance should be connected' )  { |x|   @options[:networks]          << x    }
          o.on( '-s SECURITY',    '--secgroups SECURITY',     'the security group assigned to the instance' )   { |x|   @options[:security_group]    << x    } 
          o.on( '-u USER_DATA',   '--user-data USER_DATA',    'the user data template' )                        { |x|   @options[:user_data]         =  x    }
          o.on( nil,              '--hypervisor HOST',        'the compute node you want the instance to run' ) { |x|   @options[:availability_zone] =  x    }
          o.on_command { @options[:action] = :launch   }
        end
        o.command :destroy, 'destroy and delete an instance in openstack' do 
          o.on( '-H HOSTNAME',    '--hostname HOSTNAME',      'the hostname of instance you are creating' )     { |x|   @options[:hostname]          =  x    }
          o.on_command { @options[:action] = :destroy  }
        end
        o.command :snapshot, 'snapshot a instance within openstack' do 
          o.on( '-H HOSTNAME',    '--hostname HOSTNAME',      'the hostname of the instance being snapshot' )   { |x|   @options[:hostname]          =  x    }
          o.on( '-s NAME',        '--snapshot NAME',          'the name of the snapshot you are creating' )     { |x|   @options[:snapshot]          =  x    }
          o.on( nil,              '--wait'                    'wait on the snapshot to complete' )              { |x|   @options[:wait]              =  true }
          o.on( '-f',             '--force',                  'if the snapshot image exists, delete it' )       { |x|   @options[:force]             =  true }
          o.on_command { @options[:action] = :snapshot }
        end  
      end
      Parser.parse!
      PP.pp @options
    rescue SystemExit => e 
      exit e.status

    end
    
