class nginx {
  case $::osfamily {
    'redhat', 'debian': {
      $package = 'nginx'
      $owner = 'root'
      $group = 'root'
      $docroot = '/var/www'
      $confdir = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'
    }
    'windows': {
      $package = 'nginx-service'
      $owner = 'Administrator'
      $group = 'Administrators'
      $docroot = 'C:/ProgramData/nginx/html'
      $confdir = 'C:/ProgramData/nginx/conf'
      $blockdir = 'C:/ProgramData/nginx/conf.d'
    }
    default : {
      fail("Unsupported OS (${::osfamily}) detected!")
    }
  }
  File {
    owner  => $owner,
    group  => $group,
    mode   => '0644',
  }
  package { $package:
    ensure => latest,
    before => File['nginx.conf', 'default.conf'],
  }
  file { 'docroot':
    ensure => directory,
    path   => $docroot,
  }
  file { 'index.html':
    ensure => file,
    path   => "${docroot}/index.html",
    source => 'puppet:///modules/nginx/index.html',
  }
  file { 'nginx.conf':
    ensure => file,
    path   => "${confdir}/nginx.conf",
    source => "puppet:///modules/nginx/${::osfamily}.conf",
  }
  file { 'default.conf':
    ensure => file,
    path   => "${blockdir}/default.conf",
    source => "puppet:///modules/nginx/default-${::kernel}.conf",
  }
  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => File['nginx.conf', 'default.conf'],
  }
}
