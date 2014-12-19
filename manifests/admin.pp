# Karaage Admin application class
#
# This class should not be used directly.


class karaage::admin(
  $develop=undef,
)
{

  case $::lsbdistcodename {
    precise: { $apache_conf_dir = '/etc/apache2/conf.d' }
    default: { $apache_conf_dir = '/etc/apache2/conf-enabled' }
  }

  include mariadb::python

  file {'/etc/karaage/admin_settings.py':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    content => template('karaage/admin_settings.py'),
    require => File['/etc/karaage/'],
  }

  if $develop {
    include karaage::admin::git
  }
  else
  {
    package { 'python-karaage-admin':
      ensure => present;
    }
  }
}
