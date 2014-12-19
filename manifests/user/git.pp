# Karaage user git
#
# This class installs karaage-user from git.  It's not designed to be
# used directly.


class karaage::user::git (
  $repo_uri       = 'git://github.com/NeCTAR-RC/karaage-user.git',
  $repo_revision  = undef,
  $clone_path     = '/opt/karaage-user/',
  $clone_owner    = 'root',
)
{
  vcsrepo { $clone_path:
    ensure   => 'present',
    source   => $repo_uri,
    revision => $repo_revision,
    provider => 'git',
    user     => $clone_owner,
    require  => [
      Package['git'],
      Package['python-django-south'],
      Package['python-django'],
      Package['python-django-bootstrap3'],
      Package['python-keystoneclient'],
      Package['python-django-gravatar2']],
  }

  ensure_packages(
    ['git',
    'python-django-bootstrap3',
    'python-django',
    'python-keystoneclient',
    'python-django-south',
    'python-django-gravatar2'])

  exec { 'pip-karaage-user':
    path    => ['/bin', '/usr/bin'],
    command => 'pip install -e .',
    unless  => "pip freeze | grep '-e ${repo_uri}'",
    cwd     => $clone_path,
    require => Vcsrepo[$clone_path],
  }

  file {'/etc/karaage/karaage-user.wsgi':
    ensure => file,
    source => "${clone_path}/conf/karaage-user.wsgi",
  }

  file {'/etc/karaage/user_urls.py':
    ensure => link,
    target => "${clone_path}/conf/user_urls.py",
  }
  
  exec { 'collectstatic-karaage-user':
    path    => ['/usr/bin', '/usr/local/bin'],
    command => 'kg-manage-user collectstatic --noinput',
    creates => '/var/lib/karaage-user/static',
    require => Exec['pip-karaage-user'],
  }
}
