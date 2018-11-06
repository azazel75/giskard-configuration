# -*- coding: utf-8 -*-
# :Project:   metapensiero-hosts -- load nix into the environment and install
#             it if it's necessary
# :Created:   gio 11 ott 2018 20:49:06 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

NIX=$HOME/.nix-profile/etc/profile.d/nix.sh

if [ -z $(which nix) ]; then
    if ! [ -a $NIX ]; then
        if [ -z $(which curl) ]; then
            echo "Please install 'curl' with your system tools"
        else
            echo "Installing nix..."
            curl https://nixos.org/nix/install | sh
        fi
    else
        . $HOME/.nix-profile/etc/profile.d/nix.sh
    fi
fi

nix-shell
