# Class: solr
#
# This module helps you create a multi-core solr install
# from scratch.
#
# IMPORTANT: Works only with Ubuntu as of now. Other platform
# support is most welcome. 
#
# Parameters:
#  source_url - mirror to fetch the tar/gzipped file
#  home_dir - directory to install solr
#  package - name of the package, usually the same as tar/gzipped file name w/o extension
#  solr_data_dir - solr data directory
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class solr (
      $source_url="http://apache.mirrors.lucidnetworks.net/lucene/solr/4.0.0/apache-solr-4.0.0.tgz",
      $home_dir="/usr/share/solr",
      $package="apache-solr-4.0.0",
      $solr_data_dir="/var/lib/solr/data",
      $cores = ['development','test'],
      $tomcat_connector_port="8983",
      ) {

  include solr::params
  
  class { "solr::install":
    source_url => $source_url,
    home_dir => $home_dir,
    package => $package,
    solr_data_dir => $solr_data_dir,
    cores => $cores,
    tomcat_connector_port => $tomcat_connector_port,
  }
  
}
  

