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
  description = "Name of the Juju model that holds the Vantage Slurm cluster. Ignored when model_uuid is set."
  type        = string
  default     = "slurm"
}

variable "model_owner" {
  description = "Juju user that owns the model. Needed to find the model by model_name. Ignored when model_uuid is set."
  type        = string
  default     = "admin"
}

variable "model_uuid" {
  description = "UUID of the Juju model that holds the Vantage Slurm cluster. Leave null to find the model by model_name."
  type        = string
  nullable    = true
  default     = null
}

variable "channel" {
  description = "Charmhub channel for the Vantage charms."
  type        = string
  default     = "latest/edge"
}

variable "base" {
  description = "Base for the Vantage charms. It must match the base of the Slurm applications."
  type        = string
  default     = "ubuntu@26.04"
}

# Names of the Slurm applications that are already in the model.

variable "slurmctld_app" {
  description = "Name of the existing vantage-slurmctld application."
  type        = string
  default     = "slurmctld"
}

variable "slurmrestd_app" {
  description = "Name of the existing vantage-slurmrestd application."
  type        = string
  default     = "slurmrestd"
}

variable "sackd_app" {
  description = "Name of the existing vantage-sackd (login node) application."
  type        = string
  default     = "sackd"
}

# The cluster as Vantage knows it. v8x prints these when it creates the cluster.

variable "vantage_url" {
  description = "Base URL of the Vantage platform, for example https://app.vantagecompute.ai."
  type        = string
}

variable "client_id" {
  description = "OIDC client ID of the cluster."
  type        = string
}

variable "client_secret" {
  description = "OIDC client secret of the cluster."
  type        = string
  sensitive   = true
}

variable "org_id" {
  description = "ID of the Vantage organization that owns the cluster."
  type        = string
}

variable "ldap_bind_password" {
  description = "Bind password for the Vantage LDAP directory."
  type        = string
  sensitive   = true
}

variable "ldap_uri" {
  description = "LDAP URI that sssd uses to resolve Vantage users, for example ldaps://ldap.vantagecompute.ai:636."
  type        = string
}

variable "domain_name" {
  description = "SSSD domain name."
  type        = string
  default     = "vantagecompute.ai"
}

variable "ldap_access_group" {
  description = "LDAP group whose members may log in to the cluster."
  type        = string
  default     = "slurm-users"
}

variable "deploy_presence_agent" {
  description = "Deploy the cluster presence agent, which makes Vantage show the cluster as connected. Turn this off only for tests."
  type        = bool
  default     = true
}
