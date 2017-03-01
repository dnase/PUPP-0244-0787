class nginx {
  package { 'nginx':
    ensure => latest,
    before => File['nginx.conf', 'default.conf'],
  }
  file { 'docroot':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    path   => '/var/www',
  }
  file { 'index.html':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    path   => '/var/www/index.html',
    source => 'puppet:///modules/nginx/index.html',
  }
  file { 'nginx.conf':
    ensure => file,
    path   => '/etc/nginx/nginx.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/nginx/nginx.conf',
  }
  file { 'default.conf':
    ensure => file,
    path   => '/etc/nginx/conf.d/default.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/nginx/default.conf',
  }
  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => File['nginx.conf', 'default.conf'],
  }
}
