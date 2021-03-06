# == Class: powerdns
#
# Copyright 2016 Joshua M. Keyes <joshua.michael.keyes@gmail.com>
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

class powerdns (
  $settings        = {},
  $instances       = {},
  $master          = undef,
  $slave           = undef,
  $setuid          = undef,
  $setgid          = undef,
  $package_name    = undef,
  $package_ensure  = undef,
  $service_name    = undef,
  $service_ensure  = undef,
  $service_enable  = undef,
  $config_owner    = undef,
  $config_group    = undef,
  $config_mode     = undef,
  $config_path     = undef,
  $config_purge    = undef,
  $backends        = {},
) {
  # Fail fast if we're not using a new Puppet version.
  if versioncmp($::puppetversion, '3.7.0') < 0 {
    fail('This module requires the use of Puppet v3.7.0 or newer.')
  }

  validate_hash($settings)

  if $master and $slave {
    validate_bool($master)
    validate_bool($slave)
  }

  if $setuid and $setgid {
    validate_string($setuid)
    validate_string($setgid)
  }

  contain '::powerdns::install'
  contain '::powerdns::service'

  $default_config_path  = $::osfamily ? {
    'Debian' => '/etc/powerdns',
    'RedHat' => '/etc/pdns',
    default  => undef,
  }
  $_config_path  = pick($::powerdns::config_path,  $default_config_path)

  file { $_config_path:
    ensure  => directory,
    owner   => $config_owner,
    group   => $config_group,
    purge   => $config_purge,
    recurse => $config_purge,
    force   => $config_purge,
    mode    => '0755'
  } ->
  Class['::powerdns::install'] ->
  powerdns::instance{"default":
    master => $master,
    slave => $slave,
    setuid => $setuid,
    setgid => $setgid,
    config_owner => $config_owner,
    config_group => $config_group,
    config_mode => $config_mode,
    backends => $backends,
  } ~>
  Class['::powerdns::service']

  create_resources("powerdns::instance", $instances)
  create_resources('powerdns::setting', $settings)

}

