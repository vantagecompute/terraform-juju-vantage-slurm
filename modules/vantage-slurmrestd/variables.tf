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

variable "app_name" {
  description = "Name of the Juju application deployed from this charm."
  type        = string
  default     = "slurmrestd"
}

variable "base" {
  description = "Base operating system to use for the deployed application (for example, ubuntu@26.04)."
  type        = string
  default     = "ubuntu@26.04"
}

variable "channel" {
  description = "Charmhub channel to deploy the charm from."
  type        = string
  default     = "latest/edge"
}

variable "config" {
  description = "Map of charm configuration options."
  type        = map(string)
  default     = {}
}

variable "constraints" {
  description = "Juju constraints for the deployed units, for example \"cores=2 mem=4096M root-disk=20G virt-type=virtual-machine\"."
  type        = string
  default     = null
}

variable "machines" {
  description = "Set of machine IDs to place units on. Leave null to let Juju provision machines."
  type        = set(string)
  default     = null
}

variable "model_uuid" {
  description = "UUID of the Juju model to deploy the charm into."
  type        = string
}

variable "revision" {
  description = "Revision of the charm to deploy. Null deploys the latest revision on the channel."
  type        = number
  nullable    = true
  default     = null
}

variable "units" {
  description = "Number of units to deploy. Ignored when machines is set."
  type        = number
  default     = 1
}
