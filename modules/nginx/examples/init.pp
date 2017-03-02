class { 'nginx':
  root     => '/var/www/html',
  highperf => false,
}
