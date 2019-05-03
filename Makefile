# -*- coding: utf-8 -*-
# :Project:   giskard -- targets
# :Created:   ven 14 set 2018 16:40:32 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

COPY_CLOSURE := .copy_closure
CREATE_PROFILE := .profile_created
ACTIVATE_PROFILE := .profile-activated
NIX_SRCS := $(shell find -name '*.nix')

.PHONY: build
build: result

.PHONY: copy
copy: $(COPY_CLOSURE)

.PHONY: create_profile
create_profile: $(CREATE_PROFILE)

.PHONY: activate_profile
activate_profile: $(ACTIVATE_PROFILE)

.PHONY: clean
clean:
	$(info ➤➤ Cleaning up build products...)
	@rm -f result $(COPY_CLOSURE) $(CREATE_PROFILE) $(ACTIVATE_PROFILE)

.PHONY: print_option-%
print_option-%: result
	$(info ➤➤ Printing config option "$*"...)
	@nix-instantiate --eval --strict --attr config.$* ./nixos.nix

result: $(NIX_SRCS)
	$(info ➤➤ Building configuration...)
	@nix-build --attr system ./nixos.nix

$(COPY_CLOSURE): result
	$(info ➤➤ Copying packages to $(DEST)...)
	@nix copy --to ssh://$(DEST) ./result
	@touch $@

$(CREATE_PROFILE):
$(CREATE_PROFILE): $(COPY_CLOSURE)
	$(info ➤➤ Creating new profile on $(DEST)...)
	@ssh $(DEST) nix-env --profile /nix/var/nix/profiles/system --set $(realpath result)
	@touch $@

$(ACTIVATE_PROFILE):
$(ACTIVATE_PROFILE): $(CREATE_PROFILE)
	$(info ➤➤ Activating profile on $(DEST)...)
	@ssh $(DEST) $(realpath result)/bin/switch-to-configuration switch
	@touch $@

README.html: README.rst
	@nix run nixpkgs.python3 nixpkgs.python3Packages.docutils -c rst2html5 $< > $@
