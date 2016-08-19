# == Define: powerdns::instance
#
# Copyright 2016 Chris Malton <chris@swlines.co.uk>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define powerdns::instance(
  $instance_name   = $name,
  $settings        = {},
  $master          = undef,
  $slave           = undef,
  $setuid          = undef,
  $setgid          = undef,
  $config_owner    = undef,
  $config_group    = undef,
  $config_mode     = undef,
  $config_purge    = undef,
){

  if(!defined(Class["powerdns"])){
    fail("You must define the powerdns class before creating an instance")
  }

  $default_config_path  = $::osfamily ? {
    'Debian' => '/etc/powerdns',
    'RedHat' => '/etc/pdns',
    default  => undef,
  }

  $config_owner = pick($config_owner, 'root')
  $config_group = pick($config_group, 'root')
  $config_mode  = pick($config_mode,  '0600')
  $config_path  = pick($::powerdns::config_path,  $default_config_path)

  if($instance_name == "default"){
    $config_file = "pdns.conf"
  }else{
    $config_file = "pdns-${instance_name}.conf"
  }

  validate_string($config_owner)
  validate_string($config_group)
  validate_string($config_mode)

  validate_absolute_path($config_path)

  file { "${config_path}/${confd_path}":
    ensure => directory,
    owner  => $config_owner,
    group  => $config_group,
    mode   => '0755',
    require => File[$config_path],
  } ->

  concat { "${config_path}/${config_file}":
    ensure => present,
    path   => "${config_path}/${config_file}",
    owner  => $config_owner,
    group  => $config_group,
    mode   => $config_mode,
  }

  powerdns::setting { 'daemon':
    instance => $instance_name,
    value => 'yes',
  }

  powerdns::setting { 'guardian':
    instance => $instance_name,
    value => 'yes',
  }

  powerdns::setting { 'launch':
    instance => $instance_name,
    value => '',
  }

  powerdns::setting { 'config-dir':
    instance => $instance_name,
    value => $config_path,
  }

  powerdns::setting { 'include-dir':
    instance => $instance_name,
    value => "${config_path}/${confd_path}",
  }

  if $master {
    powerdns::setting { 'master':
      instance => $instance_name,
      value => 'yes',
    }
  }

  if $slave {
    powerdns::setting { 'slave':
      instance => $instance_name,
      value => 'yes',
    }
  }

  if $setuid and $setgid {
    powerdns::setting { 'setuid':
      instance => $instance_name,
      value => $setuid,
    }

    powerdns::setting { 'setgid':
      instance => $instance_name,
      value => $setgid,
    }
  }
}