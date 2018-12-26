.. -*- coding: utf-8 -*-
.. :Project:   giskard -- Some little documentation
.. :Created:   mar 18 set 2018 22:21:11 CEST
.. :Author:    Alberto Berti <alberto@metapensiero.it>
.. :License:   GNU General Public License version 3 or later
.. :Copyright: © 2018 Alberto Berti
..

=========================
 Giskard's configuration
=========================

This is the configuration of my home server named *Giskard*. Its
configuration is made with `NixOS`__. I had it saved on the server
as NixOS own `manual`__ recommends.

After reading Gabriel's `NixOS in production`__ post I finally knew
how to obtain a bare functionality like `NixOps`__, but without NixOps
dependency and its "saved states". This a simple configuration for a
single, *bare metal*, server and there's no metadata due to a cloud
infrastructure being involved.

I copied Giskard's ``/etc/nixos/configuration.nix`` here and then
condensed Gabriel's wisdom and that of others in the ``Makefile`` and
``default.nix`` sources. What's here?

- A NixOS configuration that can be built locally and then pushed and
  installed into the designated server using ``ssh``. A new profile
  generation is created in the process so that the server's
  configuration can be rolled back in case the new one isn't working
  properly.

- The ``nixpkgs`` archive is pinned to a known release using NixOS'
  `channel commit ash`__.

- A command to query the built configuration.

- Secrets and passwords protected using `git crypt`__

How to use this repository
==========================

You will have to clone it, replace my server's configuration with
yours and change the ``DEST`` variable inside the ``Makefile``. You
will have also to update the commit hashes in ``default.nix``, have a
look here__.

Then to activate the commands run the following in a terminal:

.. code:: console

  $ source env.sh

This command will install Nix_ if it isn't installed already. In such
case it will ask you for your password because it will need superuser
privileges to create the ``/nix`` directory, where it will store its
packages.

__

Then you will have the following commands at your disposal:

**build**
  This command will build the configuration

**deploy**
  This command will perform the following actions:

  1. copy the packages to the destination;
  2. add a new profile's generation to the *system* profile
  3. activate the new configuration

**print_option** *<dotted config option>*
  This command allows you to know the final value of a configuration
  option, much like NixOS own ``nixos-option`` command but instead
  looks up the value in the built configuration. If I want to know the
  value of the ``boot.kernel.sysctl`` option, I'll execute the
  following:

  .. code:: console

    print_option boot.kernel.sysctl
    ➤➤ Printing config option "boot.kernel.sysctl"...
    { "fs.inotify.max_user_watches" = 524288; "fs.protected_hardlinks" = true; "fs.protected_symlinks" = true; "kernel.core_pattern" = "core"; "kernel.kptr_restrict" = 1; "kernel.poweroff_cmd" = "/nix/store/wpcfjs9wn6nq1fy8hma177dqd3p6813h-systemd-239/sbin/poweroff"; "kernel.printk" = 4; "kernel.yama.ptrace_scope" = 0; "net.core.somaxconn" = 1024; "net.ipv6.conf.all.disable_ipv6" = true; "net.ipv6.conf.all.forwarding" = false; "net.ipv6.conf.default.disable_ipv6" = true; }

**clean**
  will delete the subproducts of *build* and *deploy* commands execution

__ https://nixos.org
__ https://nixos.org/nixos/manual/
__ http://www.haskellforall.com/2018/08/nixos-in-production.html
__ https://nixos.org/nixops/
__ https://releases.nixos.org/nixos/18.09/nixos-18.09beta302.9fa6a261fb2/git-revision
__ https://github.com/AGWA/git-crypt
__ https://nixos.org/channels/
