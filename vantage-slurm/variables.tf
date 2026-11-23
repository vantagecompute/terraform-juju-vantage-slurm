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

variable "model_name" {
  description = "Name of the Juju model to create. Ignored when model_uuid is set."
  type        = string
  default     = "slurm"
}

variable "model_uuid" {
  description = "UUID of an existing Juju model to deploy into. Leave null to create a model named model_name."
  type        = string
  nullable    = true
  default     = null
}

variable "channel" {
  description = "Charmhub channel for every Vantage Slurm charm."
  type        = string
  default     = "latest/edge"
}

variable "base" {
  description = "Base for every Vantage Slurm charm."
  type        = string
  default     = "ubuntu@26.04"
}

variable "slurm_constraints" {
  description = "Juju constraints for each Slurm node. The default is one LXD virtual machine per node."
  type        = string
  default     = "cores=2 mem=4096M root-disk=20G virt-type=virtual-machine"
}

variable "use_client_ids" {
  description = "Set slurmctld use-client-ids, so compute nodes resolve job users with nss_slurm instead of SSSD. Keep it on when attaching vantage-agents, which installs SSSD only on the login node and controller."
  type        = bool
  default     = true
}

variable "compute_units" {
  description = "Number of slurmd compute nodes."
  type        = number
  default     = 2
}

variable "mysql_channel" {
  description = "Charmhub channel for the MySQL charm that backs slurmdbd."
  type        = string
  default     = "8.0/stable"
}

variable "mysql_base" {
  description = "Base for the MySQL charm."
  type        = string
  default     = "ubuntu@22.04"
}

variable "mysql_constraints" {
  description = "Juju constraints for the MySQL unit."
  type        = string
  default     = "mem=2048M"
}
