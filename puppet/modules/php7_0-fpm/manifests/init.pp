class php7_0-fpm {
  include apt

  exec { 'apt-update':
    command => 'apt-get update',
    path    => '/bin:/usr/bin',
    timeout => 0
  }

  apt::ppa { 'ppa:ondrej/php-7.0':
    before => Exec['apt-update']
  }

  apt::key { 'ppa:ondrej/php-7.0':
    ensure => present,
    server => 'hkp://keyserver.ubuntu.com:80',
    id     => '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
  }

  package { ['php7.0-cli', 'php7.0-fpm']:
    ensure  => latest,
    require => [
      Apt::Ppa['ppa:ondrej/php-7.0'],
      Apt::Key['ppa:ondrej/php-7.0'],
      Exec['apt-update'],
    ]
  }

  service { 'php7.0-fpm':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['php7.0-fpm'],
  }

  file { '/etc/php/7.0/fpm/pool.d/www.conf':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/php7_0-fpm/www.conf',
    notify  => Service['php7.0-fpm'],
    require => Package['php7.0-fpm'],
  }

  file { '/etc/php/7.0/fpm/php.ini':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/php7-fpm/php.ini',
    notify  => Service['php7.0-fpm'],
    require => Package['php7.0-fpm'],
  }

  include mariadb::php7_0-mysql
}
