# install flask web framework
package { 'flask':
  ensure   => '2.1.0',
  provider => 'pip3',
}
