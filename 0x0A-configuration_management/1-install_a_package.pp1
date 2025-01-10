# 1-install_a_package.pp

exec { 'install_flask':
  command => 'pip3 install Flask==2.1.0',
  path    => ['/usr/bin', '/usr/local/bin'],
  unless  => 'flask --version | grep -q "Flask 2.1.0"',
  require => Package['python3-pip'],
}

package { 'python3-pip':
  ensure => installed,
}
