{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    zon2nix = {
      url = "git+https://github.com/jcollie/zon2nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      zon2nix,
      ...
    }:
    let
      makePackages =
        system:
        import nixpkgs {
          inherit system;
        };
      forAllSystems = (
        function:
        nixpkgs.lib.genAttrs [
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-linux"
          "x86_64-darwin"
        ] (system: function (makePackages system))
      );
    in
    {
      packages = forAllSystems (pkgs: {
        zine = pkgs.callPackage ./package.nix { };
        default = self.packages.${pkgs.system}.zine;
      });
      devShells = forAllSystems (pkgs: {
        zig_0_15 = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.zig
            pkgs.pinact
            zon2nix.packages.${pkgs.system}.zon2nix
          ];
        };
        default = self.devShells.${pkgs.system}.zig_0_15;
      });
    };
}
