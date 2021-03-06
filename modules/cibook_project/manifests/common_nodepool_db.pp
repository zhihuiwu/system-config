# == Class: cibook_project::common_nodepool_node
#
class cibook_project::common_nodepool_db (
  $vhost_name                    = $::fqdn,
  $mysql_host                    = $vhost_name,
  $mysql_bind_address            = undef,
  $mysql_root_password           = undef,
  # nodepool db config
  $mysql_nodepool_db_name        = 'nodepool',
  $mysql_nodepool_user_name      = 'nodepool',
  $mysql_user_host               = '%',
  $mysql_nodepool_password       = undef,

) {

  class { '::nodepool::mysql' :
      mysql_bind_address  => $mysql_bind_address,
      mysql_root_password => $mysql_root_password,
      mysql_db_name       => $mysql_nodepool_db_name,
      mysql_user_name     => $mysql_nodepool_user_name,
      mysql_password      => $mysql_nodepool_password,
      mysql_user_host     => $mysql_user_host,
  }
}
