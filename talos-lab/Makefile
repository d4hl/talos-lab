# src:enc
PAIRS := \
	./secrets.yaml:./secrets.enc.yaml

.PHONY: encrypt decrypt updatekeys

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

# sops updatekeys
updatekeys:
	@for p in $(PAIRS); do dst=$${p##*:}; sops updatekeys "$$dst"; done
