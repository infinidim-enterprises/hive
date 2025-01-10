[
  # PXE FIX
  # { code = 150; name = "tftp-server-address"; space = "dhcp4"; type = "ipv4-address"; }
  # responses
  { code = 1; name = "priority"; space = "ipxe"; type = "int8"; }
  { code = 8; name = "keep-san"; space = "ipxe"; type = "uint8"; }
  { code = 9; name = "skip-san-boot"; space = "ipxe"; type = "uint8"; }
  { code = 85; name = "syslogs"; space = "ipxe"; type = "string"; }
  { code = 91; name = "cert"; space = "ipxe"; type = "string"; }
  { code = 92; name = "privkey"; space = "ipxe"; type = "string"; }
  { code = 93; name = "crosscert"; space = "ipxe"; type = "string"; }
  { code = 176; name = "no-pxedhcp"; space = "ipxe"; type = "uint8"; }
  { code = 177; name = "bus-id"; space = "ipxe"; type = "string"; }
  { code = 188; name = "san-filename"; space = "ipxe"; type = "string"; }
  { code = 189; name = "bios-drive"; space = "ipxe"; type = "uint8"; }
  { code = 190; name = "username"; space = "ipxe"; type = "string"; }
  { code = 191; name = "password"; space = "ipxe"; type = "string"; }
  { code = 192; name = "reverse-username"; space = "ipxe"; type = "string"; }
  { code = 193; name = "reverse-password"; space = "ipxe"; type = "string"; }
  { code = 235; name = "version"; space = "ipxe"; type = "string"; }
  { code = 203; name = "iscsi-initiator-iqn"; space = "dhcp4"; type = "string"; }
  # features
  { code = 16; name = "pxeext"; space = "ipxe"; type = "uint8"; }
  { code = 17; name = "iscsi"; space = "ipxe"; type = "uint8"; }
  { code = 18; name = "aoe"; space = "ipxe"; type = "uint8"; }
  { code = 19; name = "http"; space = "ipxe"; type = "uint8"; }
  { code = 20; name = "https"; space = "ipxe"; type = "uint8"; }
  { code = 21; name = "tftp"; space = "ipxe"; type = "uint8"; }
  { code = 22; name = "ftp"; space = "ipxe"; type = "uint8"; }
  { code = 23; name = "dns"; space = "ipxe"; type = "uint8"; }
  { code = 24; name = "bzimage"; space = "ipxe"; type = "uint8"; }
  { code = 25; name = "multiboot"; space = "ipxe"; type = "uint8"; }
  { code = 26; name = "slam"; space = "ipxe"; type = "uint8"; }
  { code = 27; name = "srp"; space = "ipxe"; type = "uint8"; }
  { code = 32; name = "nbi"; space = "ipxe"; type = "uint8"; }
  { code = 33; name = "pxe"; space = "ipxe"; type = "uint8"; }
  { code = 34; name = "elf"; space = "ipxe"; type = "uint8"; }
  { code = 35; name = "comboot"; space = "ipxe"; type = "uint8"; }
  { code = 36; name = "efi"; space = "ipxe"; type = "uint8"; }
  { code = 37; name = "fcoe"; space = "ipxe"; type = "uint8"; }
  { code = 38; name = "vlan"; space = "ipxe"; type = "uint8"; }
  { code = 39; name = "menu"; space = "ipxe"; type = "uint8"; }
  { code = 40; name = "sdi"; space = "ipxe"; type = "uint8"; }
  { code = 41; name = "nfs"; space = "ipxe"; type = "uint8"; }
  { name = "ipxe-encap-opts"; code = 175; encapsulate = "ipxe"; space = "dhcp4"; type = "empty"; }
  # { name = "custom-test"; code = 215; space = "dhcp4"; type = "string"; array = false; }
]
