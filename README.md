# bun-flake

Nix flake pinning [Bun](https://bun.sh) to the official release binaries. Each tag `vX.Y.Z` pins Bun `X.Y.Z`.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun-flake = {
      url = "github:antoine-bouteiller/bun-flake/v1.4.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, bun-flake, ...}: let
    pkgs = import nixpkgs {
      system = "aarch64-darwin";
      overlays = [bun-flake.overlays.default];
    };
  in {
    # pkgs.bun is now the pinned version.
  };
}
```

Without the overlay, use `bun-flake.packages.${system}.default`.

Supported systems are the keys of `sources` in [`bun.json`](bun.json).

## Releases

The [Update Bun](.github/workflows/update.yaml) workflow runs daily. When Bun publishes a release that has no matching tag here, it pins `bun.json` to it, checks the binary runs, then commits, tags `vX.Y.Z`, and creates a GitHub release.

To pin a version by hand, run `scripts/update.sh X.Y.Z`.
