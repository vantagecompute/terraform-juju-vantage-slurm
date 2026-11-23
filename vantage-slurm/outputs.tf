# Copyright 2026 Vantage Compute Corporation
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

output "model_uuid" {
  description = "UUID of the Juju model that holds the cluster."
  value       = local.model_uuid
}

output "applications" {
  description = "Names of the deployed Slurm applications."
  value = {
    slurmctld  = module.slurmctld.application.name
    slurmdbd   = module.slurmdbd.application.name
    slurmrestd = module.slurmrestd.application.name
    sackd      = module.sackd.application.name
    slurmd     = module.slurmd.application.name
    mysql      = juju_application.mysql.name
  }
}
