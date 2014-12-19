# Ubuntu Precise Django repository

class karaage::repo {

  apt::source { 'django1.6':
    location     => 'http://download.rc.nectar.org.au/nectar-ubuntu',
    release      => 'precise-django1.6',
    repos        => 'main',
    key          => '4CAAC2AA',
    include_src  => false,
  }
}
