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

# Slurm only: controller, accounting database, login node, compute nodes and REST API.
# Nothing here connects the cluster to Vantage. The vantage-agents module does that.

resource "juju_model" "slurm" {
  count = var.model_uuid == null ? 1 : 0
  name  = var.model_name
}

locals {
  model_uuid = var.model_uuid != null ? var.model_uuid : juju_model.slurm[0].uuid
}

module "slurmctld" {
  source      = "../modules/vantage-slurmctld"
  model_uuid  = local.model_uuid
  base        = var.base
  channel     = var.channel
  constraints = var.slurm_constraints

  # The partition is named after the slurmd application. Making it the default
  # lets users run "srun hostname" without naming a partition.
  #
  # use-client-ids makes compute nodes resolve job users with nss_slurm, so they
  # need no SSSD. The vantage-agents module puts SSSD on the login node and
  # controller only, as bundle.yaml does.
  config = {
    "default-partition" = module.slurmd.application.name
    "use-client-ids"    = tostring(var.use_client_ids)
  }
}

module "slurmdbd" {
  source      = "../modules/vantage-slurmdbd"
  model_uuid  = local.model_uuid
  base        = var.base
  channel     = var.channel
  constraints = var.slurm_constraints
}

module "slurmrestd" {
  source      = "../modules/vantage-slurmrestd"
  model_uuid  = local.model_uuid
  base        = var.base
  channel     = var.channel
  constraints = var.slurm_constraints
}

module "sackd" {
  source      = "../modules/vantage-sackd"
  model_uuid  = local.model_uuid
  base        = var.base
  channel     = var.channel
  constraints = var.slurm_constraints
}

module "slurmd" {
  source      = "../modules/vantage-slurmd"
  model_uuid  = local.model_uuid
  base        = var.base
  channel     = var.channel
  constraints = var.slurm_constraints
  units       = var.compute_units
}

resource "juju_application" "mysql" {
  name       = "mysql"
  model_uuid = local.model_uuid

  charm {
    name    = "mysql"
    base    = var.mysql_base
    channel = var.mysql_channel
  }

  constraints = var.mysql_constraints
  units       = 1
}

resource "juju_integration" "slurmctld_slurmd" {
  model_uuid = local.model_uuid
  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmd
  }
  application {
    name     = module.slurmd.application.name
    endpoint = module.slurmd.provides.slurmctld
  }
}

resource "juju_integration" "slurmctld_slurmdbd" {
  model_uuid = local.model_uuid
  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmdbd
  }
  application {
    name     = module.slurmdbd.application.name
    endpoint = module.slurmdbd.provides.slurmctld
  }
}

resource "juju_integration" "slurmctld_sackd" {
  model_uuid = local.model_uuid
  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.sackd
  }
  application {
    name     = module.sackd.application.name
    endpoint = module.sackd.provides.slurmctld
  }
}

resource "juju_integration" "slurmctld_slurmrestd" {
  model_uuid = local.model_uuid
  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmrestd
  }
  application {
    name     = module.slurmrestd.application.name
    endpoint = module.slurmrestd.provides.slurmctld
  }
}

resource "juju_integration" "slurmdbd_mysql" {
  model_uuid = local.model_uuid
  application {
    name     = module.slurmdbd.application.name
    endpoint = module.slurmdbd.requires.database
  }
  application {
    name     = juju_application.mysql.name
    endpoint = "database"
  }
}
