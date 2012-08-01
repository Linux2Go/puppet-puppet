# This class is used to configure Puppet
#
# ==Parameters
#
# [certname] certname for this host
#
class puppet($certname = undef) {

	package { puppet-common:
		ensure => present
	}

	$runinterval = $puppet::agent::runinterval
	$extra_modules = $puppet::master::extra_modules
	$puppetmaster_address = $puppet::agent::puppetmaster_address
	$mysql_password = $puppet::master::mysql_password

	file { "/etc/puppet/puppet.conf":
		content => template('puppet/puppet.conf.erb'),
		require => Package[puppet-common]
	}
}
