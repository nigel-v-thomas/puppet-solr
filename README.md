puppet-solr
===========

Solr 4 search server Puppet module.

Currently supports multi-core installations of Solr 4 on Ubuntu using the Tomcat server.  This should work in SolrCloud 
instances with minimal changes to solr.xml.erb, though this is untested. Future work should include portability with other
Linux distribution and probably Jetty support.

Based on (https://github.com/nigel-v-thomas/puppet-solr)
which was based on (https://github.com/codeinthehole/puppet-solr, https://github.com/vamsee/puppet-solr)

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
