class globus::ceph (
    Enum['present', 'absent'] $ensure = 'present',
    String $rgw_host,
    String $rgw_access_key,
    String $rgw_secret_key,
    Boolean $use_https = true,
    Boolean $verify_peer = true,
    Boolean $use_virtual_host = false,
    Boolean $enable_debug = true,
    String $debug_location = '/tmp',
    String $process_user = 'globus-ceph',
    Integer $process_threads = 2
) {

    accounts::user { "${process_user}":
        ensure => $ensure
    }

    package { 'globus-gridftp-server-ceph': 
        ensure => $ensure,
        require => Package['globus-connect-server']
    }

    file { '/etc/gridftp.d/gridftp-ceph':
        content => template('globus/gridftp-ceph.erb'),
        ensure => $ensure,
        tag => [ 'globus-config' ]
     }

     file { '/etc/globus/globus-gridftp-server-ceph.conf':
        content => template('globus/globus-gridftp-server-ceph.conf.erb'),
        ensure => $ensure,
        owner => 'root',
        group => 'root',
        mode => '0600',
        tag => [ 'globus-config' ],
        require => Package['globus-gridftp-server-ceph']
 }
}
