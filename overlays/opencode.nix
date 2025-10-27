final: prev:
let
  version = "0.15.14";
in
{
  opencode = prev.opencode.overrideAttrs (old: rec {
    inherit version;

    src = prev.fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${version}";
      sha256 = "sha256-K7TmsJm11uDNjN3fUaapM1A01FmHUSfXMiqOzhLzRI8=";
    };

    tui = old.tui.overrideAttrs (_: {
      vendorHash = "sha256-g3+2q7yRaM6BgIs5oIXz/u7B84ZMMjnxXpvFpqDePU4=";
    });

    node_modules = old.node_modules.overrideAttrs (_: {
      outputHash = "sha256-8pJBLNPuF7+wcUCNoI9z68q5Pl6Mvm1ZvIDianLPdHo=";
    });
  });
}
