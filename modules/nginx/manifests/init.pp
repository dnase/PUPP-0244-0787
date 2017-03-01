class nginx {
  case $::osfamily {
    'redhat', 'debian': {
      $package = 'nginx'
      $owner = 'root'
      $group = 'root'
      $docroot = '/var/www'
      $confdir = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'
      $logdir = '/var/log/nginx'
    }
    'windows': {
      $package = 'nginx-service'
      $owner = 'Administrator'
      $group = 'Administrators'
      $docroot = 'C:/ProgramData/nginx/html'
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
    ensure  => file,
    path    => "${docroot}/index.html",
    content => epp('nginx/index.html.epp'),
  }
  file { 'nginx.conf':
    ensure     => file,
    path       => "${confdir}/nginx.conf",
    content    => epp('nginx/nginx.conf.epp', {
      user     => $user,
      logdir   => $logdir,
      confdir  => $confdir,
      blockdir => $blockdir,
    }),
  }
  file { 'default.conf':
    ensure  => file,
    path    => "${blockdir}/default.conf",
    content => epp('nginx/default.conf.epp', {docroot => $docroot}),
  }
  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => File['nginx.conf', 'default.conf'],
  }
}
