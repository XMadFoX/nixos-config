{ master }:
final: prev:
let
  version = "1.14.25";
  masterPkgs = import master { system = prev.stdenvNoCC.hostPlatform.system; };
  bun = masterPkgs.bun;
  replaceBun = inputs: [ bun ] ++ prev.lib.filter (pkg: (pkg.pname or null) != "bun") inputs;
in
{
  opencode = prev.opencode.overrideAttrs (
    old:
    let
      src = prev.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        tag = "v${version}";
        name = "opencode-${version}-source";
        hash = "sha256-v1aaq4HWAJ5wZm9bUeaRkyKr0iYjdOhigr/I31wwhEk=";
      };
    in
    {
      inherit version src;
      nativeBuildInputs = replaceBun old.nativeBuildInputs;

      node_modules = old.node_modules.overrideAttrs (nodeOld: {
        inherit version src;
        nativeBuildInputs = replaceBun nodeOld.nativeBuildInputs;
        postPatch = ''
          substituteInPlace packages/opencode/package.json \
            --replace-fail '"partial-json": "0.1.7",' $'"partial-json": "0.1.7",\n    "prettier": "3.6.2",'
        '';
        outputHash =
          if prev.stdenvNoCC.hostPlatform.isDarwin then
            "sha256-KlE4U87sVWoB2eXngUU7w+Z3F7oqh3NPhoCRHQqQm1s="
          else
            "sha256-r0UCWhxIB4q4Te+LpXNcfexjfmI4Th2swfWOL3cUp3g=";
      });
    }
  );
}
