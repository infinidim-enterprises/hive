{ inputs, cell, ... }:

{ pkgs, lib, ... }:
let
  pkg = pkgs.system-config-printer.overrideAttrs (o:
    {
      postInstall = o.postInstall + "\nrm -rf $out/etc/systemd";
    });
in
{
  systemd.services."configure-printer@" = lib.mkForce {
    description = "Configure Plugged-In Printer";
    requires = [ "cups.socket" ];
    after = [ "cups.socket" ];

    scriptArgs = "%i";
    script = ''
      ${pkgs.system-config-printer}/etc/udev/udev-configure-printer add $1 || true
    '';
  };

  # NOTE: own file systemd.packages = with pkgs; [ system-config-printer ];
  services.udev.packages = [ pkg ];
  services.dbus.packages = [ pkg ];

  services.printing.enable = true;
  services.printing.startWhenNeeded = true;
  services.printing.webInterface = false;
  services.printing.drivers = with pkgs; [ cups-kyocera-ecosys-m552x-p502x ];

  hardware.printers =
    let name = "Kyocera_ECOSYS"; in
    {
      ensureDefaultPrinter = name;
      ensurePrinters = [{
        inherit name;
        description = "Kyocera ECOSYS P5021cdn KPDL";
        location = "home-lab";
        # TODO: https://stackoverflow.com/questions/1028891/whats-the-easiest-way-to-add-custom-page-sizes-to-a-ppd
        # https://superuser.com/questions/1026576/how-to-set-the-minimum-margin-in-cups-foomatic-driver
        # https://unix.stackexchange.com/questions/196814/printing-on-custom-paper-size-adding-paper-size-to-ppd
        # path ppd with 4 attributes for borderless a4 printing.
        ppdOptions = {
          PageSize = "A4";
          InputSlot = "Auto";
          MediaType = "Plain";
          OutputMode = "Normal";
        };
        # deviceUri = "usb://Kyocera/ECOSYS%20P5021cdn?serial=VDH1854712";
        # deviceUri = "socket://kyocera-printer.njk.local:9100";
        deviceUri = "socket://192.168.1.33:9100";
        #
        # lpinfo -m
        model = "Kyocera/Kyocera ECOSYS P5021cdn.PPD";
      }];
    };

  # networking.hosts = { "192.168.1.33" = [ "kyocera-printer.njk.local" ]; };
  environment.systemPackages = [ pkg ];
}
