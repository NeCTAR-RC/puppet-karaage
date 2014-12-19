# Karaage Class

# This module installs karaage and associated components.

class karaage(
  $debug=false,
  $fakeshib=false,
  $allowed_host=$::fqdn,
  $admins={},
  $smtp='localhost',
  $server_from_address,
  $accounts_from_address,
  $accounts_org_name='Example',
  $email_subject_prefix='[Karaage] - ',
  $email_backend_class='django.core.mail.backends.smtp.EmailBackend',

  $db_host,
  $db_port='3306',
  $db_name,
  $db_user,
  $db_pass,

  $keystone_db_host,
  $keystone_db_port='3306',
  $keystone_db_name,
  $keystone_db_user,
  $keystone_db_pass,

  $rcshibboleth_db_host,
  $rcshibboleth_db_port='3306',
  $rcshibboleth_db_name,
  $rcshibboleth_db_user,
  $rcshibboleth_db_pass,

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
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  }

  file { '/var/cache/karaage':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  }

  file {'/etc/karaage/global_settings.py':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0640',
    content => template('karaage/global_settings.py'),
    require => File['/etc/karaage/'],
  }

}
