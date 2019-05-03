# -*- coding: utf-8 -*-
# :Project:   giskard -- targets
# :Created:   ven 14 set 2018 16:40:32 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

COPY_CLOSURE := .copy-closure
CREATE_PROFILE := .profile-created
ACTIVATE_PROFILE := .profile-activated
NIX_SRCS := $(shell find -name '*.nix')
SYSTEM_DERIVATION := .system-derivation
SYSTEM_PACKAGE := .system-package

.PHONY: all
all: activate_profile

.PHONY: instantiate
instantiate: $(SYSTEM_DERIVATION)

.PHONY: build
build: $(SYSTEM_PACKAGE)

.PHONY: copy
copy: $(COPY_CLOSURE)

.PHONY: create_profile
create_profile: $(CREATE_PROFILE)

.PHONY: activate_profile
activate_profile: $(ACTIVATE_PROFILE)

.PHONY: clean
clean:
	$(info ➤➤ Cleaning up build products...)
	@rm -f result $(COPY_CLOSURE) $(CREATE_PROFILE) $(ACTIVATE_PROFILE) \
	     $(SYSTEM_DERIVATION) $(SYSTEM_PACKAGE)

.PHONY: print_option-%
print_option-%: result
	$(info ➤➤ Printing config option "$*"...)
	@nix-instantiate --eval --strict --attr config.$* ./nixos.nix

$(SYSTEM_DERIVATION): $(NIX_SRCS) shell.nix
	$(info ➤➤ Instantiating configuration...)
	@nix-instantiate --attr system ./nixos.nix > $@

result: $(NIX_SRCS)
	@nix build -f ./nixos.nix  system

$(COPY_CLOSURE): $(SYSTEM_DERIVATION)
	$(info ➤➤ Copying packages to $(DEST)...)
	@nix-copy-closure --to -s $(DEST) $(shell cat $(SYSTEM_DERIVATION))
	@touch $@

$(SYSTEM_PACKAGE): $(COPY_CLOSURE)
	$(info ➤➤ Building configuration on $(DEST)...)
	@ssh $(DEST) nix-store --realise $(shell cat $(SYSTEM_DERIVATION)) > $@

$(CREATE_PROFILE): $(SYSTEM_PACKAGE)
	$(info ➤➤ Creating new profile on $(DEST)...)
	@ssh $(DEST) nix-env --profile /nix/var/nix/profiles/system --set $(shell cat $(SYSTEM_PACKAGE))
	@touch $@

$(ACTIVATE_PROFILE): $(CREATE_PROFILE)
	$(info ➤➤ Activating profile on $(DEST)...)
	@ssh $(DEST) $(shell cat $(SYSTEM_PACKAGE))/bin/switch-to-configuration switch
	@touch $@

README.html: README.rst
	@nix run nixpkgs.python3 nixpkgs.python3Packages.docutils -c rst2html5 $< > $@
