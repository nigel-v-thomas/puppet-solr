class solr::install ($source_url, $home_dir, $solr_data_dir, $package) {
  $tmp_dir = "/var/tmp"
  

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
  
  $solr_dist_dir = "${home_dir}/dist"  
  $solr_package = "${solr_dist_dir}/${package}.war"
  $solr_home_dir = "${home_dir}"
  
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
    content => template("solr/solr.xml.erb"),
    require => [Package["tomcat6"],File[$solr_home_dir]],
    notify  => Service['tomcat6'],
  }
  
}