{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.linus = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3tGusi1VdNxad/qMykPp5l8aHMivjP9qUfKZ7uwBNh0aLtMvT8qGBam/TQMXoIrIvCq9K/hQR2LetsQ/+NmVdMS6Ejt1XGP90N0AoMIUbmMOF61JgUJv5NYS/O+7iEgAlVoyGylznufiaDk0pFrBKWVLHYsQASta5aZsnSdL1xTI5fEhjdLZpOslOStI43yY5IdsAkOpjcN6Z1eirTz0Ztft3bM0uNwNERMGHJ98EOsTMXBaTmU0js2q5el/9d08Y3mJ+5RQqm22hK+xFBdTIt5prvOO+sl6ywk/itCkfeDwKX2T3fhmEXwzS/83erRPvTrYZmguF541fHsYehFhyDWI+UE2enaSe6mXAY79dphajy1dIhph/uF18Im3mA5zHyCTrPPt+0SuneAPrnZCUagUB0QY15TD7LI/CcN+MxZazQULdX+Xsg4LC4QOg+1nPNVPosIXiwNLzGmGcow4LyUuUhRbz3UwyVMj6SKyVdXk9dc+8xGladq0GL9G+7Eg8cz1xzZOa4DzDc40Mk85EsNOWZqltgt+jTuGnIOS377U0nlmqpUURyu1jOQxylQQb7J0ESPiwvP/lb2q/GPTYDuYcslTPYoCSWd2LX5BGB5mAvQ9l9ocu26DZWB0sGp/kw13f2RxC7v7OEwvlNHD+2Vlokzhr0HyZasm0oV2y/w== openpgp:0x957E5326"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3tGusi1VdNxad/qMykPp5l8aHMivjP9qUfKZ7uwBNh0aLtMvT8qGBam/TQMXoIrIvCq9K/hQR2LetsQ/+NmVdMS6Ejt1XGP90N0AoMIUbmMOF61JgUJv5NYS/O+7iEgAlVoyGylznufiaDk0pFrBKWVLHYsQASta5aZsnSdL1xTI5fEhjdLZpOslOStI43yY5IdsAkOpjcN6Z1eirTz0Ztft3bM0uNwNERMGHJ98EOsTMXBaTmU0js2q5el/9d08Y3mJ+5RQqm22hK+xFBdTIt5prvOO+sl6ywk/itCkfeDwKX2T3fhmEXwzS/83erRPvTrYZmguF541fHsYehFhyDWI+UE2enaSe6mXAY79dphajy1dIhph/uF18Im3mA5zHyCTrPPt+0SuneAPrnZCUagUB0QY15TD7LI/CcN+MxZazQULdX+Xsg4LC4QOg+1nPNVPosIXiwNLzGmGcow4LyUuUhRbz3UwyVMj6SKyVdXk9dc+8xGladq0GL9G+7Eg8cz1xzZOa4DzDc40Mk85EsNOWZqltgt+jTuGnIOS377U0nlmqpUURyu1jOQxylQQb7J0ESPiwvP/lb2q/GPTYDuYcslTPYoCSWd2LX5BGB5mAvQ9l9ocu26DZWB0sGp/kw13f2RxC7v7OEwvlNHD+2Vlokzhr0HyZasm0oV2y/w== openpgp:0x957E5326"
  ];
}
