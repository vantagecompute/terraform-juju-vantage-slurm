# terraform-juju-vantage-slurm

Terraform plans that deploy a Slurm cluster with Juju and connect it to Vantage Compute.
The plans use the [Terraform Provider for Juju](https://documentation.ubuntu.com/terraform-provider-juju/latest/).
Every charm comes from Charmhub. This repository holds no charm source.

## Plans

| Plan | What it deploys |
|---|---|
| `vantage-slurm` | Slurm only: slurmctld, slurmd, slurmdbd, slurmrestd, sackd and MySQL, with their relations. |
| `vantage-slurm-agents` | The Vantage charms: tunnel, accounts reconciler, SSSD and presence agent. It also creates the `vantage-cluster` secret and the relations. It attaches to a Slurm cluster that is already in the model. |

The folder `modules` holds one module for each charm. The two plans use these modules.
The charms come from the `latest/edge` channel on `ubuntu@26.04`.

## Use with v8x

1. Put variable overrides in a YAML file. See the `examples` folder.
2. Deploy Slurm:

   ```bash
   uvx v8x app juju deploy vantage-slurm --config vantage-slurm-variable-overrides.yaml
   ```

3. Make a cluster record in Vantage:

   ```bash
   v8x cluster create on-prem-slurm --cloud-account on-prem-cloud --cluster-type slurm
   ```

4. Connect the cluster to Vantage:

   ```bash
   uvx v8x app juju deploy vantage-slurm-agents --cluster on-prem-slurm --config vantage-slurm-agents-variable-overrides.yaml
   ```

v8x gets the Vantage URL, the client ID and the client secret from the cluster record.

## Use with Terraform or OpenTofu

1. Clone this repository.
2. Open the plan folder, for example `vantage-slurm`.
3. Run `terraform init`, then `terraform apply`.
4. Pass variables with `-var` or a `.tfvars` file.

The plan `vantage-slurm-agents` needs `vantage_url`, `client_id` and `client_secret`.
Terraform stores these values in its state file. Keep the state file private.

Requirements: Terraform 1.6 or later (or OpenTofu), a Juju controller that you are logged in to,
and an LXD cloud that can run virtual machines.

## Releases

Each release has a tag, for example `v0.1.0`. v8x downloads a tagged release.

## Licence

Apache License 2.0. See `LICENSE`.
