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

output "applications" {
  description = "Names of the Vantage applications that were deployed."
  value = {
    tunnel         = module.tunnel.application.name
    reconciler     = module.reconciler.application.name
    sssd           = module.sssd.application.name
    presence_agent = var.deploy_presence_agent ? module.presence_agent[0].application.name : null
  }
}
