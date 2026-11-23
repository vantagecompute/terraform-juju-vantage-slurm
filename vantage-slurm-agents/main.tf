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

# Attaches the Vantage charms to a Slurm cluster that is already deployed in the model.
# It does not install Slurm. The existing applications must be the vantage-* Slurm charms,
# because the tunnel and reconciler need the vantage-oidc, slurm-jwt and slurmrestd-fqdn
# interfaces that only those charms provide.

# The model is found by name unless the caller gives its UUID.
data "juju_model" "slurm" {
  count = var.model_uuid == null ? 1 : 0
  name  = var.model_name
  owner = var.model_owner
}

locals {
  model_uuid = var.model_uuid != null ? var.model_uuid : data.juju_model.slurm[0].uuid
}

# One Juju secret holds everything the Vantage charms need to talk to Vantage.
resource "juju_secret" "cluster" {
  model_uuid = local.model_uuid
  name       = "vantage-cluster"
  value = {
    "vantage-url"        = var.vantage_url
    "client-id"          = var.client_id
    "client-secret"      = var.client_secret
    "org-id"             = var.org_id
    "ldap-bind-password" = var.ldap_bind_password
  }
}

module "tunnel" {
  source     = "../modules/vantage-cluster-tunnel"
  model_uuid = local.model_uuid
  base       = var.base
  channel    = var.channel
  config = {
    "vantage-secret" = juju_secret.cluster.secret_id
  }
}

module "reconciler" {
  source     = "../modules/vantage-slurm-accounts-reconciler"
  model_uuid = local.model_uuid
  base       = var.base
  channel    = var.channel
  config = {
    "vantage-secret" = juju_secret.cluster.secret_id
  }
}

module "sssd" {
  source     = "../modules/vantage-sssd"
  model_uuid = local.model_uuid
  base       = var.base
  channel    = var.channel
  config = {
    "vantage-secret"    = juju_secret.cluster.secret_id
    "ldap-uri"          = var.ldap_uri
    "domain-name"       = var.domain_name
    "ldap-access-group" = var.ldap_access_group
  }
}

module "presence_agent" {
  count      = var.deploy_presence_agent ? 1 : 0
  source     = "../modules/vantage-cluster-presence-agent"
  model_uuid = local.model_uuid
  base       = var.base
  channel    = var.channel
  config = {
    "vantage-secret" = juju_secret.cluster.secret_id
  }
}

# Each Vantage charm needs read access to the secret. One resource holds every
# grant, because the provider treats its list as the secret's whole access list.
# Referencing the application names makes Juju grant only after the
# applications exist. The juju-info relations below create the subordinate
# units, so they wait for this grant and every unit starts with credentials.
resource "juju_access_secret" "cluster" {
  model_uuid = local.model_uuid
  secret_id  = juju_secret.cluster.secret_id
  applications = concat(
    [
      module.tunnel.application.name,
      module.reconciler.application.name,
      module.sssd.application.name,
    ],
    module.presence_agent[*].application.name,
  )
}

# Relations, as in bundle.yaml.

resource "juju_integration" "tunnel_sackd" {
  model_uuid = local.model_uuid
  application {
    name     = module.tunnel.application.name
    endpoint = "juju-info"
  }
  application {
    name     = var.sackd_app
    endpoint = "juju-info"
  }

  depends_on = [juju_access_secret.cluster]
}

resource "juju_integration" "tunnel_oidc" {
  model_uuid = local.model_uuid
  application {
    name     = module.tunnel.application.name
    endpoint = module.tunnel.provides.vantage_oidc
  }
  application {
    name     = var.slurmctld_app
    endpoint = "vantage-oidc"
  }
}

resource "juju_integration" "tunnel_slurmrestd" {
  model_uuid = local.model_uuid
  application {
    name     = module.tunnel.application.name
    endpoint = module.tunnel.requires.slurmrestd_fqdn
  }
  application {
    name     = var.slurmrestd_app
    endpoint = "slurmrestd-fqdn"
  }
}

resource "juju_integration" "reconciler_sackd" {
  model_uuid = local.model_uuid
  application {
    name     = module.reconciler.application.name
    endpoint = "juju-info"
  }
  application {
    name     = var.sackd_app
    endpoint = "juju-info"
  }

  depends_on = [juju_access_secret.cluster]
}

resource "juju_integration" "reconciler_slurmrestd" {
  model_uuid = local.model_uuid
  application {
    name     = module.reconciler.application.name
    endpoint = module.reconciler.requires.slurmrestd_fqdn
  }
  application {
    name     = var.slurmrestd_app
    endpoint = "slurmrestd-fqdn"
  }
}

resource "juju_integration" "reconciler_jwt" {
  model_uuid = local.model_uuid
  application {
    name     = module.reconciler.application.name
    endpoint = module.reconciler.requires.slurm_jwt
  }
  application {
    name     = var.slurmctld_app
    endpoint = "slurm-jwt"
  }
}

resource "juju_integration" "sssd_sackd" {
  model_uuid = local.model_uuid
  application {
    name     = module.sssd.application.name
    endpoint = "juju-info"
  }
  application {
    name     = var.sackd_app
    endpoint = "juju-info"
  }

  depends_on = [juju_access_secret.cluster]
}

resource "juju_integration" "sssd_slurmctld" {
  model_uuid = local.model_uuid
  application {
    name     = module.sssd.application.name
    endpoint = "juju-info"
  }
  application {
    name     = var.slurmctld_app
    endpoint = "juju-info"
  }

  depends_on = [juju_access_secret.cluster]
}

# The agent is the cluster's heartbeat, and this relation creates its unit, so
# it comes after the other relations. This orders creation only: it does not
# wait for the other charms to finish setting up.
resource "juju_integration" "presence_agent_sackd" {
  count      = var.deploy_presence_agent ? 1 : 0
  model_uuid = local.model_uuid
  application {
    name     = module.presence_agent[0].application.name
    endpoint = "juju-info"
  }
  application {
    name     = var.sackd_app
    endpoint = "juju-info"
  }

  depends_on = [
    juju_access_secret.cluster,
    juju_integration.tunnel_sackd,
    juju_integration.tunnel_oidc,
    juju_integration.tunnel_slurmrestd,
    juju_integration.reconciler_sackd,
    juju_integration.reconciler_slurmrestd,
    juju_integration.reconciler_jwt,
    juju_integration.sssd_sackd,
    juju_integration.sssd_slurmctld,
  ]
}
