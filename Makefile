XDG_CONFIG_HOME ?= $(HOME)/.config
CONFIG_DIR      ?= $(XDG_CONFIG_HOME)/opencode
PAYLOAD         := config

EXCLUDE := --exclude=opencode.jsonc \
           --exclude=cli.json \
           --exclude=service.json \
           --exclude=node_modules/ \
           --exclude=package.json \
           --exclude=package-lock.json \
           --exclude=bun.lock

.PHONY: install dry-run
install:
	rsync -a --delete $(EXCLUDE) $(PAYLOAD)/ $(CONFIG_DIR)/

dry-run:
	rsync -anv --delete $(EXCLUDE) $(PAYLOAD)/ $(CONFIG_DIR)/