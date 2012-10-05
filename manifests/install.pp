class solr::install ($source_url, $install_dir, $solr_data_dir, $package) {
  $tmp_dir = "/var/tmp"
  
  $destination = "$tmp_dir/$package.tgz"

  exec { "install_dir":
    command => "echo 'ceating ${install_dir}' && mkdir -p ${install_dir}",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    creates => $install_dir
  }

  exec { "download-solr":
    command => "wget $source_url",
    unless => "test -f $destination",
    cwd => "$tmp_dir",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    require => Exec["install_dir"],
  }
  
  exec { "unpack-solr":
    command => "tar -xzf $destination --directory=$tmp_dir",
    unless => "test -d $tmp_dir/$package",
    cwd => "$tmp_dir",
    require => Exec["download-solr"],
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }
  
  $solr_dist_dir = "${install_dir}/dist"  
  $solr_doc_base = "${solr_dist_dir}/${package}.war"
  $solr_home_dir = "${install_dir}/home"
  
  # Ensure solr dist directory exist, with the appropriate privileges and copy contents of tar'd dist directory
  file { $solr_dist_dir:
    ensure => directory,
    require => Exec["unpack-solr"],
    source => "${tmp_dir}/${package}/dist/",
    recurse => true,
    group   => "tomcat6",
    owner   => "tomcat6",
  }
  
  # Ensure solr home directory exist, with the appropriate privileges and copy contents of example package to set this up
  file { $solr_home_dir:
    ensure => directory,
    require => Exec["unpack-solr"],
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