# Karaage Auth application class
#
# This class should not be used directly.


class karaage::auth(
  $develop=undef,
) {
  include karaage::karaage

  Class['karaage::karaage'] -> Class['karaage::auth']

  if $develop {
    include karaage::auth::git
  }
  else
  {
    package { 'python-karaage-auth':
      ensure => present;
    }
  }
}
