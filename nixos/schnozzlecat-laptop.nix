{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

	environment.systemPackages = with pkgs; [
    (sddm-chili-theme.overrideAttrs(old: {
			src = builtins.fetchGit {
				url = "file:///home/linus/.nixos/repos/sddm-chili";
				ref = "master";
				rev = "4e662978bf69daa555cd418e5ee3b6444be7115c";
			};
    }))
	];


  security.pam.yubico = {
     enable = true;
     debug = false;
     mode = "challenge-response";
     id = [ "23767516" ];
     control = "required";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
