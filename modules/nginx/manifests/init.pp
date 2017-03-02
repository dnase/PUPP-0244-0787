class nginx (
  String $package = $nginx::params::package,
  String $owner = $nginx::params::owner,
  String $group = $nginx::params::group,
  String $docroot = $nginx::params::docroot,
  String $confdir = $nginx::params::confdir,
  String $blockdir = $nginx::params::blockdir,
  String $user = $nginx::params::user,
  Boolean $highperf = $nginx::params::highperf,
) inherits nginx::params {
  File {
    owner  => $owner,
    group  => $group,
    mode   => '0644',
  }
  package { $package:
    ensure => latest,
    before => File['nginx.conf'],
  }
  nginx::vhost { 'default':
    docroot    => $docroot,
    servername => $::fqdn,
  }
  file { "${docroot}/vhosts":
    ensure => directory,
  }
  file { 'nginx.conf':
    ensure     => file,
    path       => "${confdir}/nginx.conf",
    content    => epp('nginx/nginx.conf.epp', {
      user     => $user,
      logdir   => $logdir,
      confdir  => $confdir,
      blockdir => $blockdir,
      highperf => $highperf,
      }),
  }
  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => File['nginx.conf'],
  }
}
