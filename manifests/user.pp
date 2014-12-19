# Karaage user portal
#
# This class should not be used directly.

class karaage::user(
  $develop=undef,
)
{

  include karaage
  include karaage::karaage
  include karaage::terms
  include karaage::keystone

  Class['karaage::terms'] -> Class['karaage::user']
  Class['karaage::keystone'] -> Class['karaage::user']
  Class['karaage::karaage'] -> Class['karaage::user']

  include mariadb::python

  file {'/etc/karaage/user_settings.py':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    content => template('karaage/user_settings.py'),
    require => File['/etc/karaage/'],
  }

  if $develop {
    include karaage::user::git
  }
  else
  {
    package { 'python-karaage-user':
      ensure => present;
    }

  }
}
