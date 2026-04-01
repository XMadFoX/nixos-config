final: prev:
let
  version = "1.2.26";
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
        hash = "sha256-+bQEfrqv9tAmXUMcvyUM0hJGpXgt09IWoKYt8I/jBlU=";
      };
    in
    {
      inherit version src;

      node_modules = old.node_modules.overrideAttrs (_: {
        inherit version src;
        outputHash =
          if prev.stdenvNoCC.hostPlatform.isDarwin then
            "sha256-KlE4U87sVWoB2eXngUU7w+Z3F7oqh3NPhoCRHQqQm1s="
          else
            "sha256-byKXLpfvidfKl8PshUsW0grrRYRoVAYYlid0N6/ke2c=";
      });
    }
  );
}
