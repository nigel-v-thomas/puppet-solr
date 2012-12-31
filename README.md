puppet-solr
===========

Solr search server, ubuntu, tomcat puppet module
Currently supports multi-core installations of Solr 4.

Based on (https://github.com/nigel-v-thomas/puppet-solr)
Which was based on (https://github.com/codeinthehole/puppet-solr, https://github.com/vamsee/puppet-solr)

Usage
======
### Minimal:

    class { "solr":
            home_dir => "/vagrant/www/deploy/solr",
    }

### Maximal:

    class { "solr":
	        source_url => "http://apache.mirrors.lucidnetworks.net/lucene/solr/4.0.0/apache-solr-4.0.0.tgz",
	        home_dir => "/usr/share/solr",
	        package => "apache-solr-4.0.0",
	        solr_data_dir => "/var/lib/solr/data",
	        cores => ["development","test"],
	        tomcat_connector_port => "8983",
    }