# Talos cluster with libvirt vms

### How to

Download bare-metal qcow2 image from `https://factory.talos.dev/`
In custom kernel parameters inject `console=ttyS0,115200 talos.dashboard.console=ttyS0`, 
so linux messages and dashboard writes to serial console

#### Install VMs
```bash
# provide qcow2 image_path in terraform.tfvars
# it will act as base for generated COW disks
cd ./terraform
terraform apply
```

#### Install cluster
```bash
# exports TALOSCONFIG and KUBECONFIG
direnv allow
or 
export TALOSCONFIG=./talosconfig KUBECONFIG=./kubeconfig

cd ./talos-lab/


# Generate new secrets, if you don't have keys to decrypt ./secrets.enc.yaml
talosctl gen secrets -o ./secrets.yaml
# or extract secrets from already generated controlplane-config
talosctl gen secrets --from-controlplane-config ./controlplane.yaml -o ./secrets.yaml


# To edit cluster modify diff.yaml files, regenerate config and apply to nodes
talosctl gen config talos-lab https://10.10.10.10:6443 \
    --with-secrets ./secrets.yaml \
    --talos-version v1.14.2 \
    --kubernetes-version 1.37.1 \
    --config-patch-control-plane @./controlplane.diff.yaml \
    --config-patch-worker @./worker.diff.yaml \
    --output-types controlplane,worker,talosconfig \
    --force

# could be skipped
talosctl config edpoints 10.10.10.11,10.10.10.12,10.10.10.13 # default for -e flag
talosctl config nodes 10.10.10.11,10.10.10.12,10.10.10.13 # default for -n flag

talosctl apply-config --insecure -n 10.10.10.11,10.10.10.12,10.10.10.13 ./controlplane.yaml
talosctl apply-config --insecure -n 10.10.10.21,10.10.10.22,10.10.10.23 ./worker.yaml

# Only once and only on one controlplane node
talosctl bootstrap -n 10.10.10.11 # or any control-plane node

talosctl kubeconfig kubeconfig -n 10.10.10.11 # or any other control-plane node
```

#### Secrets

```bash
cd ./talos-lab/

make decrypt
make encrypt
make updatekeys  # sops updatekeys
```

Onetime setup for readable diffs

```bash
git config diff.sopsdiffer.textconv "sops -d"
```
