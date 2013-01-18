class solr::install ($source_url, $home_dir, $solr_data_dir, $package, $cores, $tomcat_connector_port) {
  $tmp_dir = "/var/tmp"
  $solr_dist_dir = "${home_dir}/dist"
  $solr_package = "${solr_dist_dir}/${package}.war"
  $solr_home_dir = "${home_dir}"
  $destination = "$tmp_dir/$package.tgz"

  package {"openjdk-6-jdk":
    ensure => present,
  }
  package {"tomcat6":
    ensure => present,
    require => File['tomcat-config'],
  }

  service { "tomcat6":
    enable => "true",
    ensure => "running",
    require => [Package["tomcat6"], File['tomcat-config']],
    subscribe => File["$solr_home_dir/solr.xml"],
  }

  exec { "solr_home_dir":
    command => "echo 'ceating ${solr_home_dir}' && mkdir -p ${solr_home_dir}",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    creates => $solr_home_dir
  }

  exec { "download-solr":
    command => "wget $source_url",
    creates => "$destination",
    cwd => "$tmp_dir",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    require => Exec["solr_home_dir"],
  }

  exec { "unpack-solr":
    command => "tar -xzf $destination --directory=$tmp_dir",
    creates => "$tmp_dir/$package",
    cwd => "$tmp_dir",
    require => Exec["download-solr"],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  # Ensure solr dist directory exist, with the appropriate privileges and copy contents of tar'd dist directory
  file { $solr_dist_dir:
    ensure => directory,
    require => [Package["tomcat6"],Exec["unpack-solr"]],
    source => "${tmp_dir}/${package}/dist/",
    recurse => true,
    group   => "tomcat6",
    owner   => "tomcat6",
  }

  # unpack solr dist into home directory
  exec { "unpack-solr-war":
    command => "jar -xf $solr_package",
    cwd => "$solr_home_dir",
    creates => "$solr_home_dir/WEB-INF/web.xml",
    require => [File["$solr_dist_dir"],Package["openjdk-6-jdk"]],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  # Ensure solr home directory exist, with the appropriate privileges and copy contents of example package to set this up
  file { $solr_home_dir:
    ensure => directory,
    require => [Package["tomcat6"],Exec["unpack-solr"]],
    source => "${tmp_dir}/$package/example/solr",
    recurse => true,
    group   => "tomcat6",
    owner   => "tomcat6",
  }

  file { "/etc/tomcat6/Catalina/localhost/solr.xml":
    ensure => present,
    content => template("solr/tomcat_solr.xml.erb"),
    require => [Package["tomcat6"],File[$solr_home_dir]],
    notify  => Service['tomcat6'],
    group   => "tomcat6",
    owner   => "tomcat6",
  }

  # Tomcat config file
  # *NOTE*: This _MUST_ come first so that Tomcat starts on the correct port.
  #         If Package['tomcat6'] installs before this file is in place, it will
  #         start on the default port (8080), which can conflict with other
  #         services.

  file { "/etc/tomcat6":
    ensure => "directory",
  }

  file { 'tomcat-config':
    path => "/etc/tomcat6/server.xml",
    ensure => present,
    content => template("solr/tomcat_server.xml.erb"),
    require => File["/etc/tomcat6"],
    notify  => Service['tomcat6'],
  }

  # Fix Tomcat config permissions
  exec { 'fix-tomcat-config-permissions':
    require => [Package["tomcat6"], File['tomcat-config']],
    command => "chown tomcat6:tomcat6 /etc/tomcat6/server.xml",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  # Create cores
  solr::core {$cores:
    base_data_dir => $solr_data_dir,
    solr_home => $home_dir,
    require => Package['tomcat6'],
    notify => Service['tomcat6'],
  }

  # Create Solr file referencing new cores
  file { "$solr_home_dir/solr.xml":
    ensure => present,
    content => template("solr/solr.xml.erb"),
    notify  => Service['tomcat6'],
    group   => "tomcat6",
    owner   => "tomcat6",
  }
}
