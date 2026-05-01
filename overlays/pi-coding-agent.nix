final: prev:
let
  version = "0.71.1";
  src = prev.fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    rev = "80a439055d467001279d711c9b5d737df35113e0";
    hash = "sha256-FOR0py2stVmRwdeMr7Oh6xwYrlcyUWE9f0OEKF2rO5g=";
  };
  npmDepsHash = "sha256-irLlmq/to4x0GnNhSFVmfiuaiPx3B9l+PhlVeJSfhpU=";
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
