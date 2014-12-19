# Karaage LDAP
#
# This adds ldap support to a host for karaage.  It's not designed to
# be used outside of karaage so it is very inflexible.

class karaage::ldap (
  $domain=$::domain,
  $admin_password
) {
  $dn = inline_template('<%= @domain.split(".").collect{ |x| "dc=" + x }.join(",")%>')

  service {'slapd':
    ensure  => 'running',
    require => Package['slapd'],
  }

  package {'slapd':
    ensure       => present,
    responsefile => '/var/cache/debconf/slapd.preseed',
  }

  package {'ldap-utils':
    ensure => present
  }

  file { '/var/cache/debconf/slapd.preseed':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => "slapd slapd/domain\tstring\t${domain}\n",
    before  => Package['slapd'],
  }
  Exec {path => ['/bin/', '/usr/bin/', '/usr/sbin/']}

  $ldap_add = 'ldapadd -Y EXTERNAL -H ldapi:///'
  $ldap_modify = 'ldapmodify -Y EXTERNAL -H ldapi:///'
  $ldap_search = 'ldapsearch -Y EXTERNAL -H ldapi:///'

  #
  # Install Password Policy schema
  #
  exec {'openldap-ppolicy-schema':
    command => "${ldap_add} -f /etc/ldap/schema/ppolicy.ldif",
    unless  => "${ldap_search} -b \"cn=config\" \"(cn=*ppolicy)\" 2>/dev/null | grep -q numEntries",
    require => Service['slapd'],
  }

  file { '/var/lib/ldap/enable_ppolicy.ldif':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('karaage/enable_ppolicy.ldif'),
    require => Package['slapd'],
  }

  exec {'openldap-ppolicy-enable':
    command => "${ldap_add} -f /var/lib/ldap/enable_ppolicy.ldif",
    unless  => "${ldap_search} -b 'cn=config' '(objectClass=olcPPolicyConfig)' olcPPolicyDefault 2>/dev/null | grep -q '${dn}'",
    require => [File['/var/lib/ldap/enable_ppolicy.ldif'],
                Exec['openldap-ppolicy-schema'],
                Package['ldap-utils']],
  }

  #
  # Allow root to auth without a password
  #
  file { '/var/lib/ldap/enable_external_auth.ldif':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('karaage/enable_external_auth.ldif'),
    require => Package['slapd'],
  }

  exec {'openldap-external-auth':
    command => "${ldap_modify} -f /var/lib/ldap/enable_external_auth.ldif",
    unless => "${ldap_search} -b 'cn=config' 'olcDatabase={1}hdb' olcAccess | grep -q 'dn.exact=gidNumber=0+uidNumber=0'",
    require => [File['/var/lib/ldap/enable_external_auth.ldif'],
                Package['ldap-utils']],
  }

  #
  # Install Base Schema
  #
  file { '/var/lib/ldap/base.ldif':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('karaage/base.ldif'),
    require => Package['slapd'],
  }

  exec {'openldap-ppolicy':
    command => "${ldap_add} -f /var/lib/ldap/base.ldif",
    unless  => "${ldap_search} -b 'ou=policies,${dn}' 'cn=default' 2>/dev/null | grep -q 'cn=default,ou=policies,${dn}'",
    require => [File['/var/lib/ldap/base.ldif'],
                Exec['openldap-external-auth'],
                Exec['openldap-ppolicy-enable'],
                Package['ldap-utils']],
  }

  exec {'openldap-set-password':
    command => "echo \"dn: olcDatabase={1}hdb,cn=config\\nchangetype: modify\\nreplace: olcRootPW\\nolcRootPW: $(slappasswd -s '${admin_password}')\\n\" | ${ldap_modify}",
    unless  => "ldapsearch -H ldapi:/// -b '${dn}' -D 'cn=admin,${dn}' -w ${admin_password} '(cn=admin)'",
  }

}
