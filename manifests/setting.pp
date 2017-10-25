# == Define: powerdns::setting
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
define powerdns::setting (
  $setting = $name,
  $instance = "default",
  $ensure = 'present',
  $value  = undef,
) {

  if($instance == "default"){
    $target_file = "pdns.conf"
  }else{
    $target_file = "pdns-${instance}.conf"
  }

  concat::fragment { $name:
    ensure  => $ensure,
    target  => "${::powerdns::config_path}/${target_file}",
    content => "${setting}=${value}\n",
  }
}

