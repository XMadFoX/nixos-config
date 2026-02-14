final: prev:
let
  version = "1.1.51";
in
{
  opencode =
    (prev.opencode.overrideAttrs (old: {
      version = version;
    }))
    // {
      passthru = (prev.opencode.passthru or { }) // {
        sources = {
          "aarch64-linux" = prev.fetchurl {
            url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-linux-arm64.zip";
            hash = "sha256-v3j0oL2WL4DezOxdEKgOq4f8BkdR01zlYHUzbUUjgtEA=";
          };
          "x86_64-darwin" = prev.fetchurl {
            url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-darwin-x64.zip";
            hash = "sha256-+kycX2mbCy7p6VOKO9HequCoJi/5nT8Pf09obZEuj1A=";
          };
          "x86_64-linux" = prev.fetchurl {
            url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-linux-x64.zip";
            hash = "sha256-ca919c8b64f4a63993df70a47f383751478e8e3985c275c5d49e46a217ab97f9";
          };
        };
      };
    };
}
