class karaage::user(
  $develop=undef,
  
  $repo_uri       = 'git://github.com/NeCTAR-RC/karaage-user.git',
  $repo_revision  = undef,
  $clone_path     = '/opt/karaage-user/',
  $clone_owner    = 'root',
)
{
  case $::lsbdistcodename {
    trusty: { $apache_conf_dir = '/etc/apache2/conf-enabled' }
    precise: { $apache_conf_dir = '/etc/apache2/conf.d' }
  }
  
  ensure_packages(['python-mysqldb'])
  
  if $develop {
    vcsrepo { $clone_path:
      ensure   => 'present',
      source   => $repo_uri,
      revision => $repo_revision,
      provider => 'git',
      require  => [Package['git'],
                   Package['python-django-south'],
                   Package['python-django'],
                   Package['python-django-bootstrap3'],
                   Package['python-keystoneclient'],
                   Package['python-django-gravatar2'],],
      user     => $clone_owner,
    }
    
    ensure_packages(['git',
                     'python-django-bootstrap3',
                     'python-django',
                     'python-keystoneclient',
                     'python-django-south',
                     'python-django-gravatar2'])

    exec { 'pip-karaage-user':
      path    => ['/bin', '/usr/bin'],
      command => 'pip install -e .',
      unless  => "pip freeze | grep '-e $repo_uri'",
      cwd     => $clone_path,
      require => Vcsrepo[$clone_path],
    }
    
    file {"${apache_conf_dir}/kguser-apache.conf":
      ensure  => link,
      target  => "${clone_path}/conf/kguser-apache.conf",
      notify  => Service['apache2'],
      require => [File['/etc/karaage/'],
                  File['/etc/karaage/karaage-user.wsgi'],
                  File['/etc/karaage/user_urls.py'],],
    }

    file {"/etc/karaage/karaage-user.wsgi":
      ensure => file,
      source => "${clone_path}/conf/karaage-user.wsgi",
    }
    
    file {'/etc/karaage/user_urls.py':
      ensure => link,
      target => "${clone_path}/conf/user_urls.py",
    }
    
  }
  else
  {
    package { 'python-karaage-user':
      ensure => present;
    }
    
    file {"${apache_conf_dir}/kguser-apache.conf":
      ensure  => link,
      target => '/etc/karaage/kguser-apache.conf',
      notify  => Service['apache2'],
      require => File['/etc/karaage/'],
    }

  }
}
