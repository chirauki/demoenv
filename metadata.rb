name             'demoenv'
maintainer       'Abiquo'
maintainer_email 'marc.cirauqui@abiquo.com'
license          'Apache 2.0'
description      'Installs/Configures an Abiquo demo environment'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.5'

supports 'centos', '>= 6.5'

depends 'system', '~> 0.10.1'
depends 'abiquo', '~> 0.10.0'
depends 'abiquo_api', '~> 0.1.0'
depends 'nfs', '~> 2.2.6'
depends 'iptables', '~> 2.0.1'
depends 'chef-client', '~> 4.3.2'
depends 'ssh_authorized_keys', '~> 0.3.0'
depends 'kernel-modules', '~> 0.1.4'
