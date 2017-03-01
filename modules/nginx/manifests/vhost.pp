define nginx::vhost (
  $port = '80',
  $servername = $title,
  $docroot = "${nginx::docroot}/vhosts/${title}",
) {
  File {
    owner => $nginx::owner,
    group => $nginx::group,
    mode  => '0644',
  }
  host { $title:
    ip => $::ipaddress,
  }
  file { "nginx-vhost-${title}":
    ensure  => file,
    path    => "${nginx::blockdir}/${title}.conf",
    content => epp('nginx/vhost.conf.epp',
    {
      port       => $port,
      docroot    => $docroot,
      servername => $servername,
    }),
    notify  => Service['nginx'],
    require => File[$docroot],
  }
  file { $docroot:
    ensure => directory,
  }
  file { "${docroot}/index.html":
    ensure  => file,
    content => epp('nginx/index.html.epp',
    {
      servername => $servername,
    }),
  }
}
