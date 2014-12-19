# Karaage application class
#
# This class should not be used directly.

class karaage::karaage(
  $develop=undef,
)
{

  include mariadb::python

  if $develop {
    include karaage::karaage::git
  }
  else
  {
    package { 'python-karaage3':
      ensure => present;
    }
  }
}
