# netactuate-terraform-compute — AI Provisioning Context

Terraform module for NetActuate VMs. The key value: it outputs a ready-to-use Ansible
inventory, making it the bridge between Terraform provisioning and Ansible configuration.

Give me: API key + contract ID + locations + count + plan + SSH key → VMs provisioned +
Ansible inventory output.

## Required Inputs

| Input | Source | Example |
|-------|--------|---------|
| API key | portal.netactuate.com/account/api | `"abc123..."` |
| Contract ID | Portal API page | `"12345"` |
| Locations | Customer choice | `["LAX", "FRA", "SIN"]` |
| Plan | Customer choice | `"VR1x1x25"` |
| SSH public key path | Customer's machine | `"~/.ssh/id_ed25519.pub"` |
| Hostname prefix | Customer choice | `"myapp"` |

## What to Do

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Fill in values (never commit `terraform.tfvars`)
3. Run:
   ```bash
   terraform init
   terraform apply
   ```
4. Get the Ansible inventory:
   ```bash
   terraform output -raw ansible_inventory > inventory.ini
   ```

## The Handoff Pattern

This is what makes Terraform valuable here — the `ansible_inventory` output block generates:

```ini
[nodes]
myapp-LAX-1.example.com ansible_host=203.0.113.10 ansible_user=root
myapp-FRA-1.example.com ansible_host=203.0.113.11 ansible_user=root
myapp-SIN-1.example.com ansible_host=203.0.113.12 ansible_user=root
```

This can be piped directly into any Ansible playbook:
```bash
terraform output -raw ansible_inventory > inventory.ini
ansible-playbook -i inventory.ini /path/to/bgp.yaml
```

## Teardown

```bash
terraform destroy
```

## Common Errors

| Error | Fix |
|-------|-----|
| Provider not found | Run `terraform init` |
| API key invalid | Check `terraform.tfvars` — key must be whitelisted on portal |
| Location not found | Check PoP code against portal API page |
| SSH key error | Verify `ssh_public_key_path` points to a valid `.pub` file |
