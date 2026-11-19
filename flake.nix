{
  description = "Bun release binaries pinned to one version per tag";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    pin = builtins.fromJSON (builtins.readFile ./bun.json);
    forAllSystems = nixpkgs.lib.genAttrs (builtins.attrNames pin.sources);
  in {
    overlays.default = final: prev: {
      bun = prev.bun.overrideAttrs (old: {
        inherit (pin) version;
        __intentionallyOverridingVersion = true;
        passthru =
          old.passthru
          // {
            sources = builtins.mapAttrs (_: source:
              final.fetchurl {
                url = "https://github.com/oven-sh/bun/releases/download/bun-v${pin.version}/${source.asset}.zip";
                inherit (source) hash;
              })
            pin.sources;
          };
      });
    };

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in {
      default = pkgs.bun;
      bun = pkgs.bun;
    });
  };
}
