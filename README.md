# Talos cluster with libvirt vms

### How to

Download bare-metal qcow2 image from https://factory.talos.dev/
In custom kernel parameters inject `console=ttyS0,115200 talos.dashboard.console=ttyS0`, 
so linux messages and dashboard writes to serial console

```bash
# provide qcow2 image_path in terraform.tfvars
# it will act as base for generated COW disks
terraform apply

export TALOSCONFIG=./talosconfig KUBECONFIG=./kubeconfig

talosctl gen config cluster-name https://10.10.10.11:6443

# could be skipped
talosctl config edpoints 10.10.10.11,10.10.10.12,10.10.10.13 # default for -e flag
talosctl config nodes 10.10.10.11,10.10.10.12,10.10.10.13 # default for -n flag

talosctl apply-config --insecure -n 10.10.10.11,10.10.10.12,10.10.10.13 ./controlplane.yaml
talosctl apply-config --insecure -n 10.10.10.21,10.10.10.22,10.10.10.23 ./worker.yaml

talosctl bootstrap -n 10.10.10.11 # or any control-plane node, but only one and only once!

talosctl kubeconfig kubeconfig -n 10.10.10.11 # or any other control-plane node
```

### Secrets

All files are encrypted with sops, to decrypt there is helpfull Makefile

```bash
make decrypt
make encrypt
make edit f=talos-lab/controlplane.enc.yaml
make updatekeys  # sops updatekeys
```

Onetime setup for readable diffs

```bash
git config diff.sopsdiffer.textconv "sops -d"
```
