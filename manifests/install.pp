class solr::install ($source_url, $home_dir, $solr_data_dir, $package, $cores, $tomcat_connector_port) {
  $tmp_dir = "/var/tmp"
  $solr_dist_dir = "${home_dir}/dist"  
  $solr_package = "${solr_dist_dir}/${package}.war"
  $solr_home_dir = "${home_dir}"
  
  package {"openjdk-6-jdk":
    ensure => present,
    before => Exec["home_dir"]
  }  
  package {"tomcat6":
    ensure => present,
    before => Exec["home_dir"]
  }

  service { "tomcat6":
    enable => "true",
    ensure => "running",
    require => [Package["tomcat6"]],
    subscribe => File["$solr_home_dir/solr.xml"],
  }
  
  exec { "home_dir":
    command => "echo 'ceating ${home_dir}' && mkdir -p ${home_dir}",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    creates => $home_dir
  }

  $destination = "$tmp_dir/$package.tgz"

  exec { "download-solr":
    command => "wget $source_url",
    creates => "$destination",
    cwd => "$tmp_dir",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    require => Exec["home_dir"],
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
  file { "/etc/tomcat6/server.xml":
    ensure => present,
    content => template("solr/tomcat_server.xml.erb"),
    require => [Package["tomcat6"],File[$solr_home_dir]],
    notify  => Service['tomcat6'],
    group   => "tomcat6",
    owner   => "tomcat6",
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
