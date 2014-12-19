# Karaage terms and conditions application
#
# This class should not be used directly.

class karaage::terms(
  $develop=undef,
)
{
  include karaage::karaage

  Class['karaage::karaage'] -> Class['karaage::terms']

  if $develop {
    include karaage::terms::git
  }
  else
  {
    package { 'python-karaage-terms':
      ensure => present;
    }
  }
}
