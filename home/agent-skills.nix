{pkgs, ...}: let
  agentSkillsFrom = {
    owner,
    repo,
    rev,
    hash,
  }:
    "${pkgs.fetchFromGitHub {inherit owner repo rev hash;}}/skills";
  remoteAgentSkills = [
    (agentSkillsFrom {
      owner = "googleworkspace";
      repo = "cli";
      rev = "a3768d0e82ad83cca2da97724e46bea4ff0e6dbd";
      hash = "sha256-YyNIHbyZrLlXYtWxZY8Um19MsnLharmS+nWGWO89fsA=";
    })
    (agentSkillsFrom {
      owner = "schpet";
      repo = "linear-cli";
      rev = "90767cbd072e02efaf9a12335df848743fa953b4";
      hash = "sha256-x9Zudz7k5HQRuu2/nL/E6bDJm9caIL3AvtDT21eTWH8=";
    })
  ];
in {
  home.file.".agents/skills".source = pkgs.symlinkJoin {
    name = "agent-skills";
    paths = [./skills] ++ remoteAgentSkills;
  };
}
