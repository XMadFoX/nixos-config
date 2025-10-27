final: prev:
let
  version = "0.11.11";
in
{
  ollama = prev.ollama.overrideAttrs (old: {
    inherit version;

    src = prev.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      tag = "v${version}";
      hash = "sha256-F5Us1w+QCnWK32noi8vfRwgMofHP9vGiRFfN2UAf1vw=";
    };

    vendorHash = "sha256-SlaDsu001TUW+t9WRp7LqxUSQSGDF1Lqu9M1bgILoX4=";
  });
}

