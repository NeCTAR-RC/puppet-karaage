# Locally defined Karaage-registration settings
# Place local settings in here.
# Will override default settings

#AUP_URL = "/users/aup/"

#LOGIN_REDIRECT_URL = '/users/profile/'

# Allow anyone to request an account
#ALLOW_REGISTRATIONS = False

execfile("/etc/karaage/global_settings.py")

INSTALLED_APPS = INSTALLED_APPS + (
    'django.contrib.auth',
    'kgauth',
    'kgauth.backends.shibboleth',
    'kguser',
    'kgkeystone',
    'kgterms',
    'jsonfield'
)
