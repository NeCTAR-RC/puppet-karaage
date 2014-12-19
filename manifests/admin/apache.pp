class karaage::admin::apache ()
{
  include apache
  include karaage::admin

  case $::lsbdistcodename {
    precise: { $apache_conf_dir = '/etc/apache2/conf.d' }
    default: { $apache_conf_dir = '/etc/apache2/conf-enabled' }
  }

  file {'/etc/karaage/kgadmin-apache.conf':
    ensure  => file,
    source  => 'puppet:///modules/karaage/kgadmin-apache.conf',
    require => File['/etc/karaage/'],
  }

  file {"${apache_conf_dir}/kgadmin-apache.conf":
    ensure  => link,
    target => '/etc/karaage/kgadmin-apache.conf',
    notify  => Service['apache2'],
    require => File['/etc/karaage/'],
  }

  File['/etc/karaage/global_settings.py'] ~> Service['apache2']
  File['/etc/karaage/user_settings.py'] ~> Service['apache2']
  File["${apache_conf_dir}/kguser-apache.conf"] ~> Service['apache2']

}
