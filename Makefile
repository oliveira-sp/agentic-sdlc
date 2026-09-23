XDG_CONFIG_HOME ?= $(HOME)/.config
CONFIG_DIR      ?= $(XDG_CONFIG_HOME)/opencode
PAYLOAD         := config

.PHONY: install
install:
	rsync -a $(PAYLOAD)/ $(CONFIG_DIR)/

.PHONY: dry-run
dry-run:
	rsync -anv $(PAYLOAD)/ $(CONFIG_DIR)/

.PHONY: diff
diff:
	@scripts/compare-payload.sh diff "$(PAYLOAD)" "$(CONFIG_DIR)"

.PHONY: status
status:
	@scripts/compare-payload.sh status "$(PAYLOAD)" "$(CONFIG_DIR)"
