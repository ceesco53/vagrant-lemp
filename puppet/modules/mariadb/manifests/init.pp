class mariadb::install {
  include apt

  apt::key { 'mariadb':
    ensure => present,
    id     => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { 'mariadb':
    location    => 'http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu',
    release     => 'trusty',
    repos       => 'main',
    include     => {
      'src' => false,
    },
    require     => Apt::Key['mariadb'],
  }

  exec { 'update-apt':
    path    => '/usr/bin',
    unless  => 'dpkg -s mariadb-server-10.1',
    command => 'apt-get update',
    require => Apt::Source['mariadb'],
  }

  package { ['mariadb-server-10.1', 'mariadb-client-10.1']:
    ensure  => installed,
    require => Exec['update-apt'],
  }

  exec { 'set-mysql-root-password':
    path        => '/bin:/usr/bin',
    unless      => "mysqladmin -uroot -p${::mysql_root_password} status",
    refreshonly => true,
    command     => "mysqladmin -uroot password ${::mysql_root_password}",
    subscribe   => Package['mariadb-server-10.1'],
  }
}

class mariadb::php7_0-mysql {
  package { 'php7.0-mysql':
    ensure  => installed,
    require => Package['php7.0-fpm', 'mariadb-server-10.1'],
    notify  => Service['php7.0-fpm'],
  }
}
