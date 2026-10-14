# src:enc
PAIRS := \
	./talos-lab/controlplane.yaml:./talos-lab/controlplane.enc.yaml \
	./talos-lab/worker.yaml:./talos-lab/worker.enc.yaml \
	./talos-lab/talosconfig:./talos-lab/talosconfig.enc.yaml \
	./talos-lab/kubeconfig:./talos-lab/kubeconfig.enc.yaml

.PHONY: encrypt decrypt edit updatekeys

# *.yaml -> *.enc.yaml
encrypt:
	@for p in $(PAIRS); do \
		src=$${p%%:*}; dst=$${p##*:}; \
		cp -f "$$src" "$$dst" && sops -e -i "$$dst" \
			&& echo "encrypted: $$src -> $$dst"; \
	done

# *.enc.yaml -> *.yaml
decrypt:
	@umask 077; for p in $(PAIRS); do \
		src=$${p%%:*}; dst=$${p##*:}; \
		sops -d "$$dst" > "$$src" \
			&& echo "decrypted: $$dst -> $$src"; \
	done

# make edit f=controlplane.enc.yaml
edit:
	@test -n "$(f)" || { echo "укажи файл: make edit f=controlplane.enc.yaml"; exit 1; }
	sops "$(f)"

# sops updatekeys
updatekeys:
	@for p in $(PAIRS); do dst=$${p##*:}; sops updatekeys "$$dst"; done
