final: prev:
let
  version = "0.13.5";
in
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    inherit version;

    src = prev.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      sha256 = "sha256-GiByJg4NpllA4N4QGSyWsBNqKqKIdxicIjQpc7mHgEs=";
    };

    tui = old.tui.overrideAttrs (_: {
      vendorHash = "sha256-H+TybeyyHTbhvTye0PCDcsWkcN8M34EJ2ddxyXEJkZI=";
    });

    node_modules = old.node_modules.overrideAttrs (_: {
      outputHash = "sha256-fGf2VldMlxbr9pb3B6zVL+fW1S8bRjefJW+jliTO73A=";
    });
  });
}
