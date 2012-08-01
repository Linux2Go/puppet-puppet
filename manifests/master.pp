# This class is used to configure Puppet master.
#
# ==Parameters
#
# [autosign_cert] Autosign hosts matching this wildcard.
# [extra_modules] An array of directories holding modules (to be added
#                 to modulepath)
# [mysql_root_password] The root password for MySQL
# [mysql_password] The MySQL password for the puppet user
#
class puppet::master($autosign_cert = undef,
                     $extra_modules = undef,
                     $mysql_root_password = 'changeMe',
                     $mysql_password = 'changeMe') {

	package { "puppetmaster":
		ensure => absent
	}

	package { "puppetmaster-passenger":
		ensure => present
	}

	# set up mysql server
	class { 'mysql::server':
		config_hash => {
			'root_password' => $mysql_root_password,
			'bind_address'  => '127.0.0.1'
		}
	}

	mysql::db { puppet:
		user         => puppet,
		password     => $mysql_password,
		host         => localhost,
	}

	file { "/var/lib/puppet/reports":
		ensure => "directory",
		owner => "puppet",
		group => "puppet"
	}

	package { "ruby-activerecord":
		ensure => present
	}

	package { "ruby-mysql":
		ensure => present
	}

	File <| title == "/etc/puppet/puppet.conf" |> {
		notify +> Exec["restart-puppetmaster"]
	}

	file { "/etc/puppet/autosign.conf":
		ensure => present,
		content   => template('puppet/autosign.conf.erb'),
	}

	exec { "restart-puppetmaster":
		command => "/usr/sbin/service apache2 restart",
		require => Package["puppetmaster-passenger"],
		refreshonly => true
	}
}
