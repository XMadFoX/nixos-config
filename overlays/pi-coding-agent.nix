final: prev:
let
  version = "0.70.6";
  src = prev.fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    tag = "v${version}";
    hash = "sha256-XZUnKk+B9kWn51kRfMkfInYCz+5hVuWQBvgOm9PO9bo=";
  };
  npmDepsHash = "sha256-pEVIqp9rbuHFE6eqSmADmIXWAPey1VbD7qmOJwksz1o=";
in
{
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (_old: {
    inherit version src npmDepsHash;
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = npmDepsHash;
    };
  });
}
