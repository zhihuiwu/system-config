node "common-gearman.openstacklocal" {
    class { 'gearman': }
}

node "common-zk.openstacklocal" {
  $vhost_name = hiera('vhost_name_common', $::fqdn)

  class { '::cibook_project::common_nodepool_db':
    vhost_name                  => $vhost_name,
    mysql_bind_address          => hiera('mysql_bind_address'),
    mysql_root_password         => hiera('mysql_root_password'),
    mysql_nodepool_password     => hiera('mysql_nodepool_password'),
  }

  class { '::cibook_project::common_gerrit_db':
    mysql_root_password    => hiera('mysql_gerrit_root_password'),
    database_name          => hiera('mysql_gerrit_name'),
    database_user          => hiera('mysql_gerrit_user'),
    database_password      => hiera('mysql_gerrit_password'),
  }

  class { 'zookeeper':
    install_java => true,
    java_package => 'openjdk-7-jre-headless',
  }

}

node "gerrit" {
  package { 'ssl-cert':
    ensure => present,
  }

  exec { 'ensure ssl-cert exists':
    command => '/usr/sbin/groupadd -f ssl-cert'
  }

  # workaround since pip is not being installed as part of this module
  package { 'python-pip':
    ensure => present,
  }

  class { 'gerrit::mysql':
    mysql_root_password => 'UNSET',
    database_name       => 'reviewdb',
    database_user       => 'gerrit2',
    database_password   => '12345',
  }

  class { 'gerrit':
    manage_jeepyb                       => false,
    mysql_host                          => 'localhost',
    mysql_password                      => '12345',
    war                                 => 'http://tarballs.openstack.org/ci/gerrit/gerrit-v2.9.4.5.73392ca.war',
  }
}

node 'jenkins' {

  $vhost_name = hiera('vhost_name_jenkins', $::fqdn)

  class { '::openstackci::jenkins_node':
    vhost_name                  => $vhost_name,
    project_config_repo         => hiera('project_config_repo'),
    serveradmin                 => hiera('serveradmin', "webmaster@${vhost_name}"),
    jenkins_version             => hiera('jenkins_version', 'present'),
    jenkins_vhost_name          => hiera('jenkins_vhost_name', 'jenkins'),
    jenkins_username            => hiera('jenkins_username', 'jenkins'),
    jenkins_password            => hiera('jenkins_password', 'XXX'),
    jenkins_ssh_private_key     => hiera('jenkins_ssh_private_key'),
    jenkins_ssh_public_key      => hiera('jenkins_ssh_public_key'),
    log_server                  => hiera('log_server'),
    jjb_git_revision            => hiera('jjb_git_revision', '1.6.2'),
    jjb_git_url                 => hiera('jjb_git_url',
      'https://git.openstack.org/openstack-infra/jenkins-job-builder'),
    java_args_override          => hiera('java_args_override', '-Dhudson.model.ParametersAction.keepUndefinedParameters=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Shanghai')
  }

}

node 'log.cibook.oz' {
  class { '::openstackci::logserver':
    domain                  => hiera('domain'),
    jenkins_ssh_key         => hiera('jenkins_ssh_public_key'),
    swift_authurl           => hiera('swift_authurl', ''),
    swift_user              => hiera('swift_user', ''),
    swift_key               => hiera('swift_key', ''),
    swift_tenant_name       => hiera('swift_tenant_name', ''),
    swift_region_name       => hiera('swift_region_name', ''),
    swift_default_container => hiera('swift_default_container', ''),

node 'zuul' {
  $vhost_name = hiera('vhost_name_zuul', $::fqdn)

  class { '::openstackci::zuul_node':
    vhost_name                  => $vhost_name,
    project_config_repo         => hiera('project_config_repo'),
    gearman_server              => hiera('gearman_server'),
    gerrit_server               => hiera('gerrit_server', 'gerrit.cibook.com'),
    gerrit_user                 => hiera('gerrit_user'),
    gerrit_user_http_passwd     => hiera('gerrit_user_http_passwd'),
    gerrit_user_ssh_public_key  => hiera('gerrit_user_ssh_public_key'),
    gerrit_user_ssh_private_key => hiera('gerrit_user_ssh_private_key'),
    gerrit_ssh_host_key         => hiera('gerrit_ssh_host_key'),
    git_email                   => hiera('git_email'),
    git_name                    => hiera('git_name'),
    log_server                  => hiera('log_server'),
    log_server_public           => hiera('log_server_public'),
    smtp_host                   => hiera('smtp_host', 'localhost'),
    smtp_default_from           => hiera('smtp_default_from', "zuul@${vhost_name}"),
    smtp_default_to             => hiera('smtp_default_to', "zuul.reports@${vhost_name}"),
    zuul_revision               => hiera('zuul_revision', 'master'),
    zuul_git_source_repo        => hiera('zuul_git_source_repo', 'http://opnfv.zte.com.cn/gerrit/openstack/zuul'),
  }
}
