# Karaage Class

# This module installs karaage and associated components.

class karaage(
  $develop=undef,
  $debug=false,
  $allowed_host=$::fqdn,
  $admins={},
  $smtp='localhost',
  $server_from_address,
  $accounts_from_address,
  $accounts_org_name='Example',
  $email_subject_prefix='[Karaage] - ',
  $email_backend=undef,

  $db_host,
  $db_port='3306',
  $db_name,
  $db_user,
  $db_pass,

  $keystone_leader_role,
  $keystone_member_role,
  $keystone_endpoint,
  $keystone_token,

  $ldap_uri,
  $ldap_user,
  $ldap_password,
  $ldap_tls_ca=undef,
  $ldap_require_tls=false,
  $ldap_start_tls=false,

  $secret_key,
)
{
  include apache

  if $::lsbdistcodename == 'precise': {
    # Set up repositories
    class { 'karaage::repo':
      stage => setup,
    }
  }

  class { 'karaage::karaage': }
  class { 'karaage::auth': }
  class { 'karaage::terms': }
  class { 'karaage::keystone': }
  class { 'karaage::user': }

  Class['karaage::terms'] -> Class['karaage::user']
  Class['karaage::keystone'] -> Class['karaage::user']
  Class['karaage::karaage'] -> Class['karaage::user']

  Class['karaage::terms'] -> Class['karaage::keystone']
  Class['karaage::karaage'] -> Class['karaage::keystone']

  Class['karaage::karaage'] -> Class['karaage::auth']

  Class['karaage::karaage'] -> Class['karaage::terms']

  if $email_backend {
    $email_backend_class = $email_backend
  } else {
    if $develop {
      $email_backend_class = 'django.core.mail.backends.console.EmailBackend'
    } else {
      $email_backend_class = 'django.core.mail.backends.smtp.EmailBackend'
    }
  }

  file {
    '/var/log/karaage/django.log':
      owner   => 'www-data',
      group   => 'www-data';
    '/var/log/karaage/karaage.log':
      owner   => 'www-data',
      group   => 'www-data';
  }

  file {'/etc/karaage/':
    ensure  => directory;
  }

  file { '/var/log/karaage/':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
  }

  file { '/var/cache/karaage':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
  }

  file {'/etc/karaage/global_settings.py':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    content => template('karaage/global_settings.py'),
    notify  => Service['apache2'],
    require => File['/etc/karaage/'],
  }

  file {'/etc/karaage/user_settings.py':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    content => template('karaage/user_settings.py'),
    notify  => Service['apache2'],
    require => File['/etc/karaage/'],
  }
}
