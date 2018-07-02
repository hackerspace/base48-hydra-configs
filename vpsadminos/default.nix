{ }:

let
  pkgs = import <nixpkgs>{};
in with (import ../lib.nix { inherit pkgs; });
with pkgs.lib;
let
  defaults = globalDefaults // {
    nixexprinput = "vpsadminos";
    nixexprpath = "os/release.nix";
  };
  primary_jobsets = {
    vpsadminos-unstable = defaults // {
      description = "vpsadminos-unstable";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/vpsfreecz/vpsadminos master";
        nixpkgs = mkFetchGithub "https://github.com/nixos/nixpkgs-channels.git nixos-unstable-small";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
    vpsadminos-master = defaults // {
      description = "vpsadminos-master";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/vpsfreecz/vpsadminos master";
        nixpkgs = mkFetchGithub "https://github.com/nixos/nixpkgs.git master";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
    vpsadminos-vpsfree = defaults // {
      description = "vpsadminos-vpsfree";
      inputs = {
        vpsadminos = mkFetchGithub "https://github.com/vpsfreecz/vpsadminos master";
        nixpkgs = mkFetchGithub "https://github.com/vpsfreecz/nixpkgs.git vpsadminos";
        supportedSystems2 = { type = "nix"; value = ''[ "x86_64-linux" ]''; emailresponsible = false; };
      };
    };
  };

  jobsetsAttrs = primary_jobsets;
in {
  jobsets = pkgs.writeText "spec.json" (builtins.toJSON jobsetsAttrs);
}
