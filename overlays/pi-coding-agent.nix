final: prev:
let
  version = "0.87.1";
  src = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-GUhlq6t+l6iiViOZ0bkV28v3ZDqcLvEwpZpYZ5JAyDk=";
  };
  npmDepsHash = "sha256-JBIYoP2vvRNz1HONNvDJ1U3c+nmCJ7/VgNthRTkrkIA=";
  modelDataHash = "sha256-Bxja2vqg4mXU7JzTO82EsRVGMoQyOlwLylGL6X9fCxA=";
  modelData =
    prev.runCommand "pi-coding-agent-model-data-${version}"
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
    inherit
      version
      src
      npmDepsHash
      modelData
      ;
    # The inherited package fetches a version-specific npm tarball here.
    # Use our generated catalog instead, and skip its tar extraction.
    preConfigure = "";
    passthru = old.passthru // {
      inherit modelData;
    };
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = npmDepsHash;
    };
    preBuild = ''
      cp -r ${modelData} packages/ai/src/providers/data
      chmod -R +w packages/ai/src/providers/data
    '';
    buildPhase = ''
      runHook preBuild

      # Build workspace dependencies before the packages that import them.
      npx tsgo -p packages/telemetry/tsconfig.build.json
      npx tsgo -p packages/ai/tsconfig.build.json
      npx tsgo -p packages/chord/tsconfig.build.json
      npx tsgo -p packages/tui/tsconfig.build.json
      npx tsgo -p packages/agent/tsconfig.build.json
      npx tsgo -p packages/protocol/tsconfig.build.json
      npx tsgo -p packages/client/tsconfig.build.json
      npm run build --workspace=packages/coding-agent

      runHook postBuild
    '';
    postInstall = ''
      local nm="$out/lib/node_modules/pi-monorepo/node_modules"

      # Replace workspace deps needed at runtime with real copies.
      for ws in @earendil-works/chord:packages/chord \
                @earendil-works/pi-ai:packages/ai \
                @earendil-works/pi-agent-core:packages/agent \
                @earendil-works/pi-client:packages/client \
                @earendil-works/pi-protocol:packages/protocol \
                @earendil-works/pi-telemetry:packages/telemetry \
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
