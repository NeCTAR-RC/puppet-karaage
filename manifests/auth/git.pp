# Karaage auth git
#
# This class installs karaage-auth from git.  It's not designed to be
# used directly.


class karaage::auth::git(
  $repo_uri       = 'git://github.com/NeCTAR-RC/karaage-auth.git',
  $repo_revision  = undef,
  $clone_path     = '/opt/karaage-auth/',
  $clone_owner    = 'root',
) {
  vcsrepo { $clone_path:
    ensure   => 'present',
    source   => $repo_uri,
    revision => $repo_revision,
    provider => 'git',
    require  => Package['git'],
    user     => $clone_owner,
  }

  ensure_packages(['git'])

  exec { 'pip-karaage-auth':
    path    => ['/bin', '/usr/bin'],
    command => 'pip install -e .',
    unless  => "pip freeze | grep '-e ${repo_uri}'",
    cwd     => $clone_path,
    require => Vcsrepo[$clone_path],
  }
}
