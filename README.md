# netactuate-terraform-compute

Terraform module for provisioning Ubuntu 24.04 LTS VMs on NetActuate's global edge network.
Deploys across multiple locations with a single `terraform apply` and outputs a ready-to-use
Ansible inventory.

## Prerequisites

- **Terraform 1.0+** or **OpenTofu**
- A NetActuate API key ([portal.netactuate.com/account/api](https://portal.netactuate.com/account/api))
- An SSH public key

### Install Terraform

**macOS:**
```bash
brew install terraform
```

**Linux:**
```bash
# Using tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
tfenv install latest
tfenv use latest
```

Or download the binary directly from [terraform.io/downloads](https://www.terraform.io/downloads).

**Windows:**
```powershell
winget install Hashicorp.Terraform
```

Or use WSL2 with the Linux instructions above.

### NetActuate Terraform Provider

The NetActuate Terraform provider is installed automatically when you run `terraform init`.
It is downloaded from the Terraform Registry and shared across all modules on your system.
Each module in this collection is an independent, self-contained project with its own
`main.tf`, `variables.tf`, and `outputs.tf` — you can use any module on its own without
the others.

## Configuration

### Step 1: Copy the example tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

**Never commit `terraform.tfvars`** — it contains your API key and is gitignored.

### Step 2: Fill in your values

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `api_key` | string | NetActuate API key (sensitive) | `"abc123..."` |
| `contract_id` | string | Billing contract ID | `"12345"` |
| `locations` | list(string) | PoP codes to deploy in | `["LAX", "FRA", "SIN"]` |
| `vm_count_per_location` | number | VMs per location (default: 1) | `1` |
| `plan` | string | VM sizing plan | `"VR1x1x25"` |
| `os_image` | string | OS image name | `"Ubuntu 24.04 LTS (20240423)"` |
| `hostname_prefix` | string | Hostname prefix | `"myapp"` |
| `domain` | string | Domain suffix | `"example.com"` |
| `ssh_public_key_path` | string | Path to SSH public key | `"~/.ssh/id_ed25519.pub"` |

## Usage

```bash
# Initialize providers
terraform init

# Preview what will be created
terraform plan

# Create all VMs
terraform apply

# View the generated Ansible inventory
terraform output ansible_inventory

# View individual server IPs
terraform output server_ips
```

## Handoff to Ansible

The `ansible_inventory` output generates a ready-to-use inventory file. To use it with any
Ansible playbook:

```bash
# Save the inventory to a file
terraform output -raw ansible_inventory > inventory.ini

# Use it with any playbook
ansible-playbook -i inventory.ini your-playbook.yaml
```

**Example:** Provision VMs with Terraform, then configure BGP with the bird2 playbook:

```bash
# In this directory
terraform apply
terraform output -raw ansible_inventory > ../netactuate-ansible-bgp-bird2/hosts

# In the bird2 playbook directory
cd ../netactuate-ansible-bgp-bird2
ansible-playbook bgp.yaml
```

## Teardown

```bash
terraform destroy
```

This terminates all VMs and cancels billing.

## AI-Assisted (Claude Code / Cursor / Copilot)

```
Provision NetActuate VMs with Terraform:

- API Key: <YOUR_API_KEY>
- Contract ID: <YOUR_CONTRACT_ID>
- Locations: LAX, FRA, SIN
- Plan: VR1x1x25
- Hostname prefix: myapp

Please:
1. Copy terraform.tfvars.example to terraform.tfvars and fill in values
2. Run terraform init && terraform apply
3. Show me the ansible_inventory output
4. Save it to inventory.ini
```

## Need Help?

- NetActuate support: support@netactuate.com
- [NetActuate API Documentation](https://www.netactuate.com/docs/)
- [Terraform NetActuate Provider](https://registry.terraform.io/providers/netactuate/netactuate/latest)
- [NetActuate Portal](https://portal.netactuate.com)
