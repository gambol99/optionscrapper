OptionScrapper!
----------------

Is a wrapper for the OptionsParser (optparse) gem which makes using subcommand like cli easier to define. Note, all the options configuration is passed directly to optparse; so anything it supports, this will support;

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

Will produce the following usage menu;

    [jest@starfury tests]$ ./test.rb --help

    Usage: test.rb [options]
        -h, --help                       display this usage menu
        -S, --stack NAME                 the name of the openstack you wish to connect
        -c, --config CONFIG              the configuration file to read credentials
            --dry-run                    perform a dry run
        -v, --verbose                    switch on verbose mode

        commands : -------------------------------------------------------------
        launch (ln)                      launch a instance in to openstack cluster
        destroy (des)                    destroy and delete an instance in openstack
        snapshot (sp)                    snapshot a instance within openstack
        ------------------------------------------------------------------------

        launch : description: launch a instance in to openstack cluster
        ------------------------------------------------------------------------

        -H, --hostname HOSTNAME          the hostname of instance you are creating
        -i, --image IMAGE                the image you wish to boot from
        -f, --flavor FLAVOR              the flavor the instance should work from
        -k, --keypair KEYPAIR            the keypair the instance should use
        -n, --network NETWORK            the network the instance should be connected
        -s, --secgroups SECURITY         the security group assigned to the instance
        -u, --user-data USER_DATA        the user data template
            --hypervisor HOST            the compute node you want the instance to run
        -e, --error                      cause an error

        destroy : description: destroy and delete an instance in openstack
        ------------------------------------------------------------------------

        -H, --hostname HOSTNAME          the hostname of instance you are creating

        snapshot : description: snapshot a instance within openstack
        ------------------------------------------------------------------------

        -H, --hostname HOSTNAME          the hostname of the instance being snapshot
        -s, --snapshot NAME              the name of the snapshot you are creating
            --wait                       wait on the snapshot to complete
        -f, --force                      if the snapshot image exists, delete it

Or to print just the menu of the subcommand

    [jest@starfury tests]$ ./test.rb ln --help
    launch : description: launch a instance in to openstack cluster
    ------------------------------------------------------------------------

    -H, --hostname HOSTNAME          the hostname of instance you are creating
    -i, --image IMAGE                the image you wish to boot from
    -f, --flavor FLAVOR              the flavor the instance should work from
    -k, --keypair KEYPAIR            the keypair the instance should use
    -n, --network NETWORK            the network the instance should be connected
    -s, --secgroups SECURITY         the security group assigned to the instance
    -u, --user-data USER_DATA        the user data template
        --hypervisor HOST            the compute node you want the instance to run
    -e, --error                      cause an error

----------

Mixing Options
--------------

The order of the options is not enforced, thus global options can be placed anywhere on the command line. If however, there is a conflict, i.e. the subcommand has the same flag/s as a global option, the subcommand takes precedence.

Contributing
------------

 - Fork it
 - Create your feature branch (git checkout -b my-new-feature)
 - Commit your changes (git commit -am 'Add some feature')
 - Push to the branch (git push origin my-new-feature)
 - Create new Pull Request
 - If applicable, update the README.md
