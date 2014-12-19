# Karaage karaage git
#
# This class installs karaage from git.  It's not designed to be
# used directly.


class karaage::karaage::git (
  $repo_uri       = 'git://github.com/NeCTAR-RC/karaage.git',
  $repo_revision  = undef,
  $clone_path     = '/opt/karaage/',
  $clone_owner    = 'root',
) {
  vcsrepo {$clone_path:
    ensure   => 'present',
    source   => $repo_uri,
    revision => $repo_revision,
    user     => $clone_owner,
    provider => 'git',
    require  => [
      Package['git'],
      Package['django-ajax-selects'],
      Package['django-simple-captcha'],
      Package['python-alogger'],
      Package['python-django'],
      Package['python-django-celery'],
      Package['python-django-jsonfield'],
      Package['python-django-model-utils'],
      Package['python-django-south'],
      Package['python-django-xmlrpc'],
      Package['python-matplotlib'],
      Package['python-tldap']],
  }

  ensure_packages(
    ['git',
     'django-ajax-selects',
     'django-simple-captcha',
     'python-alogger',
     'python-django',
     'python-django-celery',
     'python-django-jsonfield',
     'python-django-model-utils',
     'python-django-south',
     'python-django-xmlrpc',
     'python-matplotlib',
     'python-tldap'])

  exec { 'pip-karaage':
    path    => ['/bin', '/usr/bin'],
    command => 'pip install -e .',
    unless  => "pip freeze | grep '-e ${repo_uri}'",
    cwd     => $clone_path,
    require => vcsrepo[$clone_path],
  }
}
