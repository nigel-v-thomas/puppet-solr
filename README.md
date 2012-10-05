puppet-solr
===========

Solr search server, ubuntu, tomcat puppet module
Based on (https://github.com/codeinthehole/puppet-solr, https://github.com/vamsee/puppet-solr)

Usage
======
Minimal:

class { "solr":
        install_dir => "/vagrant/www/deploy/solr",
}

Maximal:

class { "solr":
      source_url => "http://mirror.ox.ac.uk/sites/rsync.apache.org/lucene/solr/3.6.1/apache-solr-3.6.1.tgz",
      install_dir => "/usr/share/solr",
      package => "apache-solr-3.6.1",
      solr_data_dir => "/var/lib/solr/data",
}