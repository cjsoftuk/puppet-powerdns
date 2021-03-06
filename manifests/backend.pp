# == Define: powerdns::backend
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
define powerdns::backend ( 
  $backend_name = $name,
  $options = {},
) {
  validate_string($name)

  # Construct the backend class name.
  $backend = "::powerdns::backend::${backend_name}"

  # If the backend doesn't exist, it's not supported.
  if defined($backend) == false {
    fail("This module does not support the ${backend_name} backend for PowerDNS!")
  }

  # Evaluate the backend with any specified options.
  $class = { "${name}_internal" => $options }
  # Ensure PowerDNS is installed before the backend is evaluated.
  create_resources("${backend}", $class)
}
