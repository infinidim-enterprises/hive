{ inputs, cell, ... }:

{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkMerge
    mkIf
    hasAttr
    mkDefault;

  filters = with (lib // builtins);
    let
      filter_paths =
        mapAttrsToList
          (k: v: v.src.outPath)
          (filterAttrs (k: v: hasPrefix "adguard-filters" k) pkgs.sources);
      filter_paths_list = splitString "\n" (fileContents
        (pkgs.runCommandNoCC "filter_paths" { buildInputs = [ pkgs.findutils ]; } ''
          for path in ${concatStringsSep " " filter_paths}; do find "$path" -type f -name \*.txt >> $out;done
        ''));
    in
    imap1
      (id: url: {
        inherit id url;
        enabled = true;
        name = "filter_" + (toString id);
      })
      filter_paths_list;

  safe_fs_patterns = with (lib // builtins);
    map (e: e.url) filters;
in
mkMerge
  [
    {
      # NOTE: https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
      # required for quic lookups
      boot.kernel.sysctl."net.core.rmem_max" = 7500000;
      boot.kernel.sysctl."net.core.wmem_max" = 7500000;
    }

    (mkIf config.networking.networkmanager.enable {
      networking.networkmanager.insertNameservers = config.services.adguardhome.settings.dns.bind_hosts;
    })

    {
      services.adguardhome.enable = true;
      services.adguardhome.host = mkDefault "127.0.0.1";
      services.adguardhome.port = mkDefault 8888;
      services.adguardhome.mutableSettings = false;
      services.adguardhome.settings = {

        inherit filters;
        filtering = { inherit safe_fs_patterns; };

        auth_attempts = 5;
        beta_bind_port = 0;
        block_auth_min = 15;
        clients = {
          persistent = [ ];
          runtime_sources = {
            arp = true;
            dhcp = true;
            hosts = true;
            rdns = true;
            whois = true;
          };
        };
        debug_pprof = false;
        dhcp = {
          dhcpv4 = {
            gateway_ip = "";
            icmp_timeout_msec = 1000;
            lease_duration = 86400;
            options = [ ];
            range_end = "";
            range_start = "";
            subnet_mask = "";
          };
          dhcpv6 = {
            lease_duration = 86400;
            ra_allow_slaac = false;
            ra_slaac_only = false;
            range_start = "";
          };
          enabled = false;
          interface_name = "";
          local_domain_name = "lan";
        };

        dns = {
          aaaa_disabled = true;
          all_servers = true;
          allowed_clients = [ ];
          anonymize_client_ip = false;
          bind_hosts = [ "127.0.0.1" ];
          blocked_hosts = [ "version.bind" "id.server" "hostname.bind" ];
          blocked_response_ttl = 10;
          # blocked_services = [ ];
          blocking_ipv4 = "";
          blocking_ipv6 = "";
          blocking_mode = "default";
          bogus_nxdomain = [ ];
          bootstrap_dns = [
            "8.8.8.8"
            "8.8.4.4"
            "94.140.14.14"
            "94.140.15.15"
            "2001:4860:4860::8888"
            "2001:4860:4860::8844"
          ];
          cache_optimistic = false;
          cache_size = 4194304;
          cache_time = 30;
          cache_ttl_max = 0;
          cache_ttl_min = 0;
          disallowed_clients = [ ];
          # edns_client_subnet = false;
          enable_dnssec = false;
          fastest_addr = false;
          fastest_timeout = "1s";
          filtering_enabled = true;
          filters_update_interval = 24;
          ipset = [ ];
          local_ptr_upstreams = [ ];
          max_goroutines = 300;
          parental_block_host = "family-block.dns.adguard.com";
          parental_cache_size = 1048576;
          parental_enabled = false;
          port = mkDefault 53;
          private_networks = [ ];
          protection_enabled = true;
          querylog_enabled = true;
          querylog_file_enabled = true;
          querylog_interval = "2160h";
          querylog_size_memory = 1000;
          ratelimit = 0;
          ratelimit_whitelist = [ ];
          refuse_any = true;
          rewrites = [ ];
          safebrowsing_block_host = "standard-block.dns.adguard.com";
          safebrowsing_cache_size = 1048576;
          safebrowsing_enabled = false;
          safesearch_cache_size = 1048576;
          safesearch_enabled = false;
          statistics_interval = 90;
          trusted_proxies = [ "127.0.0.0/8" "::1/128" ];
          upstream_dns = [
            "https://dns10.quad9.net/dns-query"
            "https://dns.adguard-dns.com/dns-query"
            "https://security.cloudflare-dns.com/dns-query"
            "quic://dns.adguard-dns.com"
          ];
          # upstream_dns_file = "";
          upstream_timeout = "10s";
          # use_private_ptr_resolvers = mkDefault true;
        };

        http_proxy = "";
        language = "";
        log_compress = false;
        log_file = "";
        log_localtime = false;
        log_max_age = 3;
        log_max_backups = 0;
        log_max_size = 100;
        # os = { group = ""; rlimit_nofile = 0; user = ""; };
        # schema_version = 14;
        tls = {
          allow_unencrypted_doh = false;
          certificate_chain = "";
          certificate_path = "";
          dnscrypt_config_file = "";
          enabled = false;
          force_https = false;
          port_dns_over_quic = 853;
          port_dns_over_tls = 853;
          port_dnscrypt = 0;
          port_https = 443;
          private_key = "";
          private_key_path = "";
          server_name = "";
          strict_sni_check = false;
        };
        user_rules = [
          "@@||whatsapp.net^$important"
          "@@||web.whatsapp.com^$important"
          "@@||cache.nixos.org^$important"
          "@@||davidshield.com^$important"
          # I do use linkedin
          "@@||www.linkedin.com^$important"
          "@@||static.licdn.com^$important"
          "@@||media.licdn.com^$important"
        ];
        users = [{
          name = "admin";
          password = "$2y$05$n1jeESbnw1MsGKsqd9BiSO.GztmN5/RYO3jK.BHHhmdaoi5ZXhngW";
        }];
        verbose = false;
        web_session_ttl = 720;
        whitelist_filters = [ ];
      };
    }
  ]
