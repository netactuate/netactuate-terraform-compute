output "server_ips" {
  description = "Public IPv4 addresses of all provisioned VMs"
  value = {
    for name, server in netactuate_server.node :
    name => server.primary_ipv4
  }
}

output "ansible_inventory" {
  description = "Ansible inventory in INI format — pipe to a file and use with ansible-playbook -i"
  value = join("\n", concat(
    ["[nodes]"],
    [
      for name, server in netactuate_server.node :
      "${name}.${var.domain} ansible_host=${server.primary_ipv4} ansible_user=root"
    ],
    [""]
  ))
}
