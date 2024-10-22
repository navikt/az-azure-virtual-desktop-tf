output "hostpools" {
  value     = { for k, v in module.hostpool : k => v }
  sensitive = false
}

output "subnet_id" {
  value     = module.network.subnet_id
  sensitive = false
}