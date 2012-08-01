# This class is used to configure Puppet agent.
#
# ==Parameters
#
# [puppetmaster_address] If puppet.$domain does not resolve to your
#                        puppetmaster, you can specify its hostname
#                        here.
# [runinterval] How often (in seconds) Puppet agent will run.
#
class puppet::agent($puppetmaster_address = undef,
                    $runinterval = 120) {

	package { puppet:
		ensure => present
	}

	file { "/etc/default/puppet":
		content => template('puppet/defaults.erb'),
		notify => Exec["restart-puppet"],
	}

	File <| title == "/etc/puppet/puppet.conf" |> {
		notify +> Exec["restart-puppet"]
	}

	file { "/etc/init.d/puppet":
		mode => 0755,
		owner => root,
		group => root,
		content => template('puppet/init.erb'),
		notify => Exec["restart-puppet"]
	}

	exec { "restart-puppet":
		command => "/usr/sbin/service puppet restart",
		require => Package[puppet],
		refreshonly => true
	}
}

