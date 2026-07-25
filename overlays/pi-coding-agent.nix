final: prev:
let
  version = "0.82.1";
  src = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-LESpgd/KUoNqdBfnd1oyMN8coKm0Odbo9GYkUDry8Zk=";
  };
  npmDepsHash = "sha256-5pHRwxpKg95/phOcYHeWdvPJNtSOhiw7PRoVxsuh0RM=";
  modelDataHash = "sha256-hnNtKJlKpabGKvnskbir7sh9EltMBqj6wtqp8Ma9e+8=";
  modelData = prev.runCommand "pi-coding-agent-model-data-${version}"
    {
      nativeBuildInputs = [ prev.nodejs ];
      outputHash = modelDataHash;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      NODE_EXTRA_CA_CERTS = "${prev.cacert}/etc/ssl/certs/ca-bundle.crt";
    }
    ''
      cp -r ${src} source
      chmod -R +w source
      cd source
      node packages/ai/scripts/generate-models.ts --strict --data-only
      cp -r packages/ai/src/providers/data "$out"
    '';
in
{
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
    inherit version src npmDepsHash;
    passthru = old.passthru // { inherit modelData; };
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = npmDepsHash;
    };
    preBuild = ''
      cp -r ${modelData} packages/ai/src/providers/data
      chmod -R +w packages/ai/src/providers/data
    '';
    postInstall = ''
      local nm="$out/lib/node_modules/pi-monorepo/node_modules"

      # Replace workspace deps needed at runtime with real copies.
      for ws in @earendil-works/pi-ai:packages/ai \
                @earendil-works/pi-agent-core:packages/agent \
                @earendil-works/pi-tui:packages/tui; do
        IFS=: read -r pkg src <<< "$ws"
        rm "$nm/$pkg"
        cp -r "$src" "$nm/$pkg"
      done

      # Delete remaining workspace symlinks.
      find "$nm" -type l -lname '*/packages/*' -delete

      # Clean up now-dangling .bin symlinks.
      find "$nm/.bin" -xtype l -delete
    '';
    meta = old.meta // {
      homepage = "https://pi.dev/";
      downloadPage = "https://www.npmjs.com/package/@earendil-works/pi-coding-agent";
      changelog = "https://github.com/earendil-works/pi/releases/tag/v${version}";
    };
  });
}
