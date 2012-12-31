define solr::core($core_name = $title, $base_data_dir, $solr_home) {
  
  #Create this core's config directory
  exec { "mkdir-p-${core_name}":
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    command => "mkdir -p ${solr_home}/${core_name}/conf",
    unless => "test -d ${solr_home}/${core_name}/conf",
  }
  
  #Create this core's data directory
  exec { "mkdir-p-config-${core_name}":
    path => ['/usr/bin', '/usr/sbin', '/bin'],
    command => "mkdir -p ${base_data_dir}/${core_name}",
    unless => "test -d ${base_data_dir}/${core_name}",
  }

  
  #Finally, create the data directory where solr stores
  #its indexes with proper directory ownership/permissions.
  file { "${core_name}-data-dir":
    ensure => directory,
    path => "${base_data_dir}/${core_name}",
    owner => "tomcat6",
    group => "tomcat6",
    require => Exec["mkdir-p-config-${core_name}"],
  }
  
  file { ["${solr_home}/${core_name}/", "${solr_home}/${core_name}/conf/"]:
    ensure => directory,
    owner => "tomcat6",
    group => "tomcat6",
    require => Exec["mkdir-p-${core_name}"],
  }

  #Copy the respective solrconfig.xml file
  file { "solrconfig-${core_name}":
    ensure => file,
    path => "${solr_home}/${core_name}/conf/solrconfig.xml",
    content => template('solr/solrconfig.xml.erb'),
    require => File["${solr_home}/${core_name}/conf/"],
    group   => "tomcat6",
    owner   => "tomcat6",
  }

  #Copy the respective schema.xml file
  file { "schema-${core_name}":
    ensure => file,
    path => "${solr_home}/${core_name}/conf/schema.xml",
    content => template('solr/schema.xml.erb'),
    require => File["${solr_home}/${core_name}/conf/"],
    group   => "tomcat6",
    owner   => "tomcat6",
  }  
}
