XDG_CONFIG_HOME ?= $(HOME)/.config
CONFIG_DIR      ?= $(XDG_CONFIG_HOME)/opencode
PAYLOAD         := config

.PHONY: install dry-run
install:
	rsync -a $(PAYLOAD)/ $(CONFIG_DIR)/

dry-run:
	rsync -anv $(PAYLOAD)/ $(CONFIG_DIR)/