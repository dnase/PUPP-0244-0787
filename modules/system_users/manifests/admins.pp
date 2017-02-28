class system_users::admins {
  group { 'staff':
    ensure => present,
  }
  user { 'admin':
    ensure => present,
    gid    => 'staff',
    shell  => '/bin/csh',
  }
}
