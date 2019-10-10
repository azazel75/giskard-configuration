# -*- coding: utf-8 -*-
# :Project:   giskard -- mail config
# :Created:   lun 17 set 2018 15:43:01 CEST
# :Author:    Alberto Berti <alberto@metapensiero.it>
# :License:   GNU General Public License version 3 or later
# :Copyright: © 2018 Alberto Berti
#

{ config, pkgs, ... }: {
    services.postfix =
      let
        hostName = "azazel.it";
        relay = "orphu.arstecnica.it";
        iface = config.networking.interfaces.enp1s0;
        ipv4 = (builtins.head iface.ipv4.addresses).address;
        acmeDirectory = config.security.acme.certs.${hostName}.directory;
        sslCertificate = "${acmeDirectory}/fullchain.pem";
        sslCertificateKey = "${acmeDirectory}/key.pem";
      in {
        enable = true;
        enableHeaderChecks = false;
        setSendmail = true;
        hostname = hostName;
        destination = [
          "localhost"
        ];
        enableSubmission = false;
        relayHost = relay;
        config = {
          smtpd_tls_auth_only = false;
          message_size_limit = "100480000";
          mailbox_size_limit = "1004800000";

          smtp_bind_address = "0.0.0.0";

          smtpd_sasl_local_domain = "orphu";
          smtpd_sasl_auth_enable = true;
          smtpd_sasl_security_options = "noanonymous";
          smtpd_sasl_type = "cyrus";
          broken_sasl_auth_clients = true;

          smtpd_tls_received_header = true;
          smtpd_relay_restrictions = [
            "reject_non_fqdn_recipient"
            "reject_unknown_recipient_domain"
            "permit_mynetworks"
            "permit_sasl_authenticated"
            "reject_unauth_destination"
          ];
          smtpd_client_restrictions = [
            "permit_mynetworks"
            "permit_sasl_authenticated"
            "reject_unknown_reverse_client_hostname" # reject when no reverse PTR
          ];
          smtpd_helo_required = "yes";
          smtpd_helo_restrictions = [
            "permit_mynetworks"
            "permit_sasl_authenticated"
            "reject_invalid_helo_hostname"
            "reject_non_fqdn_helo_hostname"
            "reject_unknown_helo_hostname"
          ];

          # Add some security
          smtpd_recipient_restrictions = [
            "reject_unknown_sender_domain"    # prevents spam
            "reject_unknown_recipient_domain" # prevents spam
            "reject_unauth_pipelining"        # prevent bulk mail spam
            "permit_sasl_authenticated"
            "permit_mynetworks"
            "reject_unauth_destination"
          ];
        };

        sslCert = sslCertificate;
        sslKey  = sslCertificateKey;
      };
  }
