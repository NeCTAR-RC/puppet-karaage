class karaage::admin::git (
  $repo_uri       = 'git://github.com/NeCTAR-RC/karaage-admin.git',
  $repo_revision  = undef,
  $clone_path     = '/opt/karaage-admin/',
  $clone_owner    = 'root',
)
{
  vcsrepo { $clone_path:
    ensure   => 'present',
    source   => $repo_uri,
    revision => $repo_revision,
    provider => 'git',
    require  => Package['git'],
    user     => $clone_owner,
  }

  ensure_packages(['git'])

  exec { 'pip-karaage-admin':
    path    => ['/bin', '/usr/bin'],
    command => 'pip install -e .',
    unless  => "pip freeze | grep '-e ${repo_uri}'",
    cwd     => $clone_path,
    require => Vcsrepo[$clone_path],
  }

  file {'/etc/karaage/karaage-admin.wsgi':
    ensure => file,
    source => "${clone_path}/conf/karaage-admin.wsgi",
  }

  file {'/etc/karaage/admin_urls.py':
    ensure => link,
    target => "${clone_path}/conf/admin_urls.py",
  }
  
  exec { 'collectstatic-karaage-admin':
    path    => ['/usr/bin', '/usr/local/bin'],
    command => 'kg-manage collectstatic --noinput',
    creates => '/var/lib/karaage-admin/static',
    require => Exec['pip-karaage-admin'],
  }

}
