{ nixpkgs ? <nixpkgs>, declInput ? {} }:

let
  pkgs = import nixpkgs {};
  defaultSettings = {
    enabled = "1";
    hidden = false;
    description = "";
    input = "jobs";
    path = "default.nix";
    keep = 1;
    shares = 42;
    interval = 300;
    inputs = {
      jobs = {
        type = "git";
        value = "git://github.com/hackerspace/base48-hydra-configs";
      };
      nixpkgs = {
        type = "git";
        value = "git://github.com/NixOS/nixpkgs";
      };
      supportedSystems = {
        type = "nix";
        value = ''[ \"x86_64-linux\" ]'';
      };
    };
    mail = true;
    mailOverride = "srk@48.io";
  };
  jobsetsAttrs = with pkgs.lib; mapAttrs (name: settings: recursiveUpdate defaultSettings settings) (rec {
    # if we decide to add default.nix to base48-hydra-configs
    #hydra-jobs-master = {
    #  keep = 3;
    #  shares = 420;
    #};
    nixos-small-master = {
      input = "nixpkgs";
      path = "nixos/release-small.nix";
    };
  });
  fileContents = with pkgs.lib; ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF
    cat > $out <<EOF
    {
      ${concatStringsSep "," (mapAttrsToList (name: settings: ''
        "${name}": {
            "enabled": ${settings.enabled},
            "hidden": ${if settings.hidden then "true" else "false"},
            "description": "${settings.description}",
            "nixexprinput": "${settings.input}",
            "nixexprpath": "${settings.path}",
            "checkinterval": ${toString settings.interval},
            "schedulingshares": ${toString settings.shares},
            "enableemail": ${if settings.mail then "true" else "false"},
            "emailoverride": "${settings.mailOverride}",
            "keepnr": ${toString settings.keep},
            "inputs": {
              ${concatStringsSep "," (mapAttrsToList (inputName: inputSettings: ''
                "${inputName}": { "type": "${inputSettings.type}", "value": "${inputSettings.value}", "emailresponsible": false }
              '') settings.inputs)}
            }
        }
      '') jobsetsAttrs)}
    }
    EOF
  '';
in {
  jobsets = pkgs.runCommand "spec.json" {} fileContents;
}

