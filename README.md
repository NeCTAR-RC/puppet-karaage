# Puppet Karaage

This module provides configuration and installation of the Karaage
identity management solution.


# Node configuration

There are 4 classes that can be used to enable Karaage on a node.

``` ruby
  include karaage  # [required]
  include karaage::user::apache  # [optional]
  include karaage::admin::apache  # [optional]
  include karaage::ldap  # [optional]
```

It's expected that Hiera will be used to configure the Karaage on the
node.

## Karaage Flags
### Development

Turning on `develop` flag will cause the package to be installed from
git. Each module can be toggled into development mode separately.
It's important to only do this on a clean installation as it doesn't
remove any packages.


``` yaml
karaage::karaage::develop: true
karaage::user::develop: true
karaage::terms::develop: true
karaage::auth::develop: true
karaage::keystone::develop: true
karaage::admin::develop: true
```

Debug will turn on Django debug mode.  Stack traces will be printed
for the user.

``` yaml
karaage::debug: true
```

To enable the Mock shibboleth service.  This will allow you to log in
as any user without needing shibboleth.

``` yaml
karaage::fakeshib: true
```


### Configuration

Set the Django secret_key that is used to sign sessions.
``` yaml
karaage::secret_key: secret
```

Email addresses.  The `server_from_address` is used to set the Admin
email address.  The `accounts_from_address` is used to communicate
account information with users.
``` yaml
karaage::server_from_address: admin@localhost
karaage::accounts_from_address: admin@localhost
```

Database configuration.
``` yaml
karaage::db_host: 127.0.0.1
karaage::db_name: karaage
karaage::db_user: karaage
karaage::db_pass: secret
```

### Migration data sources
Keystone database configuration.  This is only used during the
migration to Karaage.
``` yaml
karaage::keystone_db_host: 127.0.0.1
karaage::keystone_db_name: keystone
karaage::keystone_db_user: keystone
karaage::keystone_db_pass: secret
```

RCShibboleth database configuration.  This is only used during the
migration to Karaage.
``` yaml
karaage::rcshibboleth_db_host: 127.0.0.1
karaage::rcshibboleth_db_name: rcshibboleth
karaage::rcshibboleth_db_user: rcshibboleth
karaage::rcshibboleth_db_pass: secret
```

### Datastores

Keystone
``` yaml
karaage::keystone_leader_role: TenantManager
karaage::keystone_member_role: Member
karaage::keystone_endpoint: http://localhost:35357/v3/
karaage::keystone_token: ADMIN
```

LDAP
``` yaml
karaage::ldap_uri: 'ldap://karaage1.dev.rc.nectar.org.au'
karaage::ldap_user: 'cn=admin,dc=localhost
karaage::ldap_password: secret
```

## karaage::ldap Server configuration

This flag is used to configure the optional LDAP server that is
installed with the `karaage::ldap` class.  The `karaage::ldap::domain`
option should be a domain name, this will be converted into a DN.
``` yaml
karaage::ldap::admin_password: secret
karaage::ldap::domain: localhost
```
