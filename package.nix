{
  lib,
  callPackage,
  stdenvNoCC,
  zig_0_15,
}:
let
  zig_hook = zig_0_15.hook.overrideAttrs {
    zig_default_flags = "-Dcpu=baseline -Doptimize=Debug --color off";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "zine";
  src = lib.cleanSource ./.;
  deps = callPackage ./build.zig.zon.nix { name = "zine-cache"; };
  nativeBuildInputs = [
    zig_hook
  ];
  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];
  meta = {
    mainProgram = "zine";
    license = lib.licenses.mit;
  };
})
