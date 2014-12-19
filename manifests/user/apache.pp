# Karaage user Apache2 configuration.
#
# This class configures and installs the karaage user interface using
# Apache2.

class karaage::user::apache
{
  include apache
  include karaage::user

  case $::lsbdistcodename {
    precise: { $apache_conf_dir = '/etc/apache2/conf.d' }
    default: { $apache_conf_dir = '/etc/apache2/conf-enabled' }
  }

  file {'/etc/karaage/kguser-apache.conf':
    ensure  => file,
    source  => 'puppet:///modules/karaage/kguser-apache.conf',
    require => File['/etc/karaage/'],
  }

  file {"${apache_conf_dir}/kguser-apache.conf":
    ensure  => link,
    target  => '/etc/karaage/kguser-apache.conf',
    require => File['/etc/karaage/'],
  }

  File['/etc/karaage/global_settings.py'] ~> Service['apache2']
  File['/etc/karaage/user_settings.py'] ~> Service['apache2']
  File["${apache_conf_dir}/kguser-apache.conf"] ~> Service['apache2']
}
