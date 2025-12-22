#!/bin/bash

cd infra || exit 1

terraform init -reconfigure -backend=true || {
  echo "Terraform initialization failed." >&2
  exit 1
}

# Azure VM public IP
VM_IP=$(terraform output -raw vm_public_ip)

if [[ -z "$VM_IP" ]]; then
  echo "Could not obtain the public IP address of the VM"
  exit 1
fi

cd ..

SSH_KEY_PATH="${GOGS_SSH_KEY_PATH:-$HOME/.ssh/gogs_azure_key.pem}"

cat <<EOF >ansible/inventory.ini
[gogs_server]
gogs ansible_host=$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=$SSH_KEY_PATH
EOF

echo "inventory.ini file generated with IP: $VM_IP"
