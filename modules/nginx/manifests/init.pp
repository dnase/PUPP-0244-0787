class nginx (
  String $root = undef,
  Boolean $highperf = true,
) {
  case $::osfamily {
    'redhat', 'debian': {
      $package = 'nginx'
      $owner = 'root'
      $group = 'root'
      $default_docroot = '/var/www'
      $confdir = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'
      $logdir = '/var/log/nginx'
    }
    'windows': {
      $package = 'nginx-service'
      $owner = 'Administrator'
      $group = 'Administrators'
      $default_docroot = 'C:/ProgramData/nginx/html'
      $confdir = 'C:/ProgramData/nginx/conf'
      $blockdir = 'C:/ProgramData/nginx/conf.d'
      $logdir = 'C:/ProgramData/nginx/logs'
    }
    default : {
      fail("Unsupported OS (${::osfamily}) detected!")
    }
  }
  $user = $::osfamily ? {
    'redhat'  => 'nginx',
    'debian'  => 'www-data',
    'windows' => 'nobody',
  }
  $docroot = $root ? {
    undef   => $default_docroot,
    default => $root,
  }
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
