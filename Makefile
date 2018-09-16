# -*- coding: utf-8 -*-
# :Project:   giskard -- targets
# :Created:   ven 14 set 2018 16:40:32 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

DEST := root@giskard
COPY_CLOSURE := .copy_closure
CREATE_PROFILE := .profile_created
ACTIVATE_PROFILE := .profile-activated

.PHONY: build
build: result

.PHONY: copy
copy: $(COPY_CLOSURE)

.PHONY: create_profile
create_profile: $(CREATE_PROFILE)

.PHONY: activate_profile
activate_profile: $(ACTIVATE_PROFILE)

result: *.nix
	nix-build --attr system ./nixos.nix

$(COPY_CLOSURE): result
	nix copy --to ssh://$(DEST) ./result
	@touch $@

$(CREATE_PROFILE):
$(CREATE_PROFILE): $(COPY_CLOSURE)
	ssh $(DEST) nix-env --profile /nix/var/nix/profiles/system --set $(realpath result)
	@touch $@

$(ACTIVATE_PROFILE):
$(ACTIVATE_PROFILE): $(CREATE_PROFILE)
	ssh $(DEST) $(realpath result)/bin/switch-to-configuration switch
	@touch $@
