# TODO:  There are many globus options not covered by this module.  
# PR welcome if you add them as parameters and include in conf templates
# Alternately the module can be forked and the base conf template altered to fit your needs

class globus (
	String $loglevels = 'ERROR,WARN,INFO',  # Options:   ERROR, WARN, INFO, TRANSFER, DUMP, ALL
	String $globus_user,
	String $globus_password,
	Optional[String] $restrict_paths,   #  pattern like 'RW/path,RW/path2-*'
	Optional[String] $default_directory,
	Boolean $enable_sharing = false,
	Boolean $manage_firewall = false,  # use puppetlabs/firewall resources to configure rules
	Boolean $run_setup = true,  # always run gcs-setup after changes to globus-connect-server.conf
	String $firewall_order = '100',
	Boolean $manage_repo = true,
	Array[String] $gftp_ctrl_src = [ '54.237.254.192/29']
) {

	File <| tag == 'globus-config' |> 
	~> Service['globus-gridftp-server']
	
	if $manage_firewall {
		firewall { "${firewall_order} allow GridFTP control channels for Globus":
			dport => '2811',
			action => 'accept',
			source => $gftp_ctrl_src
		}

		firewall { "${firewall_order} allow MyProxy traffic for Globus":
			dport => '7512',
			action => 'accept',
			source => $gftp_ctrl_src
		}

		firewall { "${firewall_order} allow GridFTP data channels for Globus":
			dport => '50000-51000',
			action => 'accept'
		}

	}

	$globus_sharing = $enable_sharing ? {
		true => 'True',
		default => 'False'
	}

	if $manage_repo {
		package { 'globus-toolkit-repo': 
			ensure => installed,
			provider => rpm, 
			source => "http://downloads.globus.org/toolkit/globus-connect-server/globus-connect-server-repo-latest.noarch.rpm",
		} 
	}

	package { 'globus-connect-server':
			ensure => installed
	} ->

	file { '/etc/gridftp.d': 
		ensure => directory,
	} ->

	file { '/etc/gridftp.d/globus-connect-server-gridftp-logging':
		content => template("globus/gridftp-logging.erb"),
		tag => [ 'globus-config' ]
	} ->

	file { "/etc/globus-connect-server.conf":
		ensure => $ensure,
		owner => 'root',
		group => 'root',
		mode => '0600',
		content => template("globus/globus-connect-server.conf.erb"),
		tag => [ 'globus-config' ]
	}

	if $run_setup {
		exec { 'globus-setup':
			command => '/bin/globus-connect-server-setup',
			refreshonly => true,
			subscribe => File['/etc/globus-connect-server.conf']
	 	}
	}

	 service { 'globus-gridftp-server': ensure => running }
}
