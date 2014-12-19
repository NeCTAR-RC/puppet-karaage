# -*- coding: utf-8 -*-


# Globally defined Karaage settings
# These settings will be used for karaage-admin and karaage-registration.

# Some of these values have sensible defaults. Settings that don't have a sensible
# default must be configured manually.

# Other Django settings are also possible, this list is not a comprehensive
# list of all settings.

import celery.app
celery.app.app_or_default()

###
### Django settings
###

# A boolean that turns on/off debug mode.
#
# Never deploy a site into production with DEBUG turned on.
#
# Did you catch that? NEVER deploy a site into production with DEBUG turned on.
#
# One of the main features of debug mode is the display of detailed error
# pages. If your app raises an exception when DEBUG is True, Django will
# display a detailed traceback, including a lot of metadata about your
# environment, such as all the currently defined Django settings (from
# settings.py).
#
# default: DEBUG = False
#
<% if @develop %>DEBUG = True<% end %>

# A list of strings representing the host/domain names that this Django site
# can serve. This is a security measure to prevent an attacker from poisoning
# caches and password reset emails with links to malicious hosts by submitting
# requests with a fake HTTP Host header, which is possible even under many
# seemingly-safe web server configurations.
ALLOWED_HOSTS = [ "<%= allowed_host %>" ]

# Whether to use a secure cookie for the session cookie. If this is set to
# True, the cookie will be marked as “secure,” which means browsers may ensure
# that the cookie is only sent under an HTTPS connection.
#
# default: SESSION_COOKIE_SECURE = True
#
<% if @develop %>SESSION_COOKIE_SECURE = False<% end %>

# A tuple that lists people who get code error notifications. When DEBUG=False
# and a view raises an exception, Django will email these people with the full
# exception information. Each member of the tuple should be a tuple of (Full
# name, email address).
ADMINS = (<% admins.each_pair do |name, email| %>
    ('<%= name %>', '<%= email %>'),
<% end %>)

# A tuple in the same format as ADMINS that specifies who should get broken
# link notifications when BrokenLinkEmailsMiddleware is enabled.
MANAGERS = ADMINS

# A tuple of middleware classes to use.
MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    # NOTE (RS) disabled because it requires djang 1.6
    # 'django.middleware.common.BrokenLinkEmailsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'karaage.middleware.threadlocals.ThreadLocals',
    'karaage.middleware.saml.SamlUserMiddleware',
    'tldap.middleware.TransactionMiddleware',
)


# A dictionary containing the settings for all databases to be used with
# Django. It is a nested dictionary whose contents maps database aliases to a
# dictionary containing the options for an individual database.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '<%= db_name %>',
        'USER': '<%= db_user %>',
        'PASSWORD': '<%= db_pass %>',
        'HOST': '<%= db_host %>',
        'PORT': '<%= db_port %>',
        'ATOMIC_REQUESTS': True,
    }
}


LDAP = {
     'default': {
          'ENGINE': 'tldap.backend.fake_transactions',
          'URI': '<%= @ldap_uri %>',
          'USER': '<%= @ldap_user %>',
          'PASSWORD': '<%= @ldap_password %>',
          'REQUIRE_TLS': <% if @ldap_require_tls %>True<% else %>False<% end %>,
          'START_TLS ': <% if @ldap_start_tls %>True<% else %>False<% end %>,
          'TLS_CA' : <% if @ldap_tls_ca %>'<%= @ldap_tls_ca %>'<% else %>None<% end %>,
     }
}


MACHINE_CATEGORY_DATASTORES = {
    'default' : [
        {
            'DESCRIPTION': 'Default LDAP datastore',
            'ENGINE': 'kgkeystone.datastore.ldap.MachineCategoryDataStore',
            'LDAP': 'default',
            'ACCOUNT': 'karaage.datastores.ldap_schemas.openldap_account',
            'GROUP': 'karaage.datastores.ldap_schemas.openldap_account_group',
            'PRIMARY_GROUP': "institute",
            'DEFAULT_PRIMARY_GROUP': "dummy",
            'HOME_DIRECTORY': "/home/%(uid)s",
            'LOCKED_SHELL': "/bin/false",
        },
        {
            'DESCRIPTION': 'Keystone datastore',
            'ENGINE': 'kgkeystone.datastore.keystone.MachineCategoryDataStore',
            'VERSION': 'v3',
            'ENDPOINT': '<%= keystone_endpoint %>',
            'TOKEN': '<%= keystone_token %>',

            'LEADER_ROLE': '<%= keystone_leader_role %>',
            'MEMBER_ROLE': '<%= keystone_member_role %>',
        },
    ],
    'dummy' : [
    ],
}


# The email address that error messages come from, such as those sent to ADMINS
# and MANAGERS.
SERVER_EMAIL = '<%= server_from_address %>'

# The host to use for sending email.
EMAIL_HOST = '<%= smtp %>'

# Subject-line prefix for email messages sent with django.core.mail.mail_admins
# or django.core.mail.mail_managers. You’ll probably want to include the
# trailing space.
EMAIL_SUBJECT_PREFIX = '<%= email_subject_prefix %>'

# The email backend to use
EMAIL_BACKEND = '<%= email_backend_class %>'

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'Australia/Melbourne'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-au'

# A secret key for a particular Django installation. This is used to provide
# cryptographic signing, and should be set to a unique, unpredictable value.
SECRET_KEY = '<%= secret_key %>'

# A data structure containing configuration information. The contents of this
# data structure will be passed as the argument to the configuration method
# described in LOGGING_CONFIG.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
    'handlers': {
        'django_file': {
            'level': 'WARNING',
            'class': 'logging.FileHandler',
            'filename': '/var/log/karaage/django.log',
            'formatter': 'verbose',
        },
        'karaage_file': {
            'level': 'WARNING',
            'class': 'logging.FileHandler',
            'filename': '/var/log/karaage/karaage.log',
            'formatter': 'verbose',
        },
#        'ldap_file': {
#            'level': 'DEBUG',
#            'class': 'logging.FileHandler',
#            'filename': '/var/log/karaage/ldap.log',
#            'formatter': 'verbose',
#        },
#        'gold_file': {
#            'level': 'DEBUG',
#            'class': 'logging.FileHandler',
#            'filename': '/var/log/karaage/gold.log',
#            'formatter': 'verbose',
#       },
#       'slurm_file': {
#            'level': 'DEBUG',
#            'class': 'logging.FileHandler',
#            'filename': '/var/log/karaage/slurm.log',
#            'formatter': 'verbose',
#        },
    },
    'loggers': {
        'django': {
            'handlers': ['django_file'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'karaage': {
            'handlers': ['karaage_file'],
            'level': 'DEBUG',
            'propagate': True,
        },
#        'karaage.datastores.ldap': {
#            'handlers': ['ldap_file'],
#            'level': 'DEBUG',
#            'propagate': True,
#        },
#        'karaage.datastores.gold': {
#            'handlers': ['gold_file'],
#            'level': 'DEBUG',
#            'propagate': True,
#        },
#        'karaage.datastores.slurm': {
#            'handlers': ['slurm_file'],
#            'level': 'DEBUG',
#            'propagate': True,
#        },
    },
}


###
### Karaage settings
###

# Users are advised to contact this address if having problems.
# This is also used as the from address in outgoing emails.
ACCOUNTS_EMAIL = '<%= accounts_from_address %>'

# This organisation name, used in outgoing emails.
ACCOUNTS_ORG_NAME = '<%= accounts_org_name %>'

# Registration base URL - Used in email templates
# Uncomment to override default
#
# default: REGISTRATION_BASE_URL = 'https://<hostname>/users'
#
# REGISTRATION_BASE_URL = 'https://accounts.example.org/users'

# Is Shibboleth supported?
#
# default: SHIB_SUPPORTED = False
#
SHIB_SUPPORTED = True

# Path to AUP policy. Note that setting this will not disable the Karaage
# default page, it might be better to replace the AUP with a file in
# /etc/karaage/templates/aup.html if required.
#
# default: Django template
#
# AUP_URL = "https://site.example.org/users/aup/"

# Do we allow anonymous users to request accounts?
#
# default:  ALLOW_REGISTRATIONS = False
#
# ALLOW_REGISTRATIONS = False

# Do we allow any logged in user to access all usage information?
#
# default: USAGE_IS_PUBLIC = True
#
# USAGE_IS_PUBLIC = False

# Settings to restrict the valid list of email addresses we allow in
# applications.  EMAIL_MATCH_TYPE can be "include" or "exclude".  If "include"
# then the email address must match one of the RE entries in EMAIL_MATCH_LIST.
# If "exclude" then then email address must not match of the the RE entries in
# EMAIL_MATCH_LIST.
#
# default: allow any email address
#
# EMAIL_MATCH_TYPE="include"
# EMAIL_MATCH_LIST=["@vpac.org$", "@v3.org.au$", "^tux@.*au$"]

# Username validation configuration
USERNAME_VALIDATION_RE = '[-@.\w]+'
USERNAME_VALIDATION_ERROR_MSG = u'Usernames can only contain letters, numbers and underscores'

# Project validation configuration
PROJECT_VALIDATION_RE = '[-.@&\w]+'

# Group validation configuration
GROUP_VALIDATION_RE = '[-.@&\w]+'

PASSWORD_HASHERS = (
    'kgkeystone.hasher.SHA512CryptPasswordHasher',
)