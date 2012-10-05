# This is the generic solr parameters
class solr::params {
  case $operatingsystem {
    Ubuntu: {
    }
    default: {
      fail("Operating system, $operatingsystem, is not supported by the tomcat module")
    }
  }
}
