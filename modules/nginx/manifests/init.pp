class nginx {
  package { 'nginx':
    ensure => latest,
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
}
