# Karaage keystone integration
#
# This class should not be used directly.

class karaage::keystone(
  $develop=undef,
)
{
  include karaage::karaage
  include karaage::terms

  Class['karaage::terms'] -> Class['karaage::keystone']
  Class['karaage::karaage'] -> Class['karaage::keystone']

  if $develop {
    include karaage::keystone::git
  }
  else
  {
    package { 'python-karaage-keystone':
      ensure => present;
    }
  }
}
