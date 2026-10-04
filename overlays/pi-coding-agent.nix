final: prev:
let
  version = "0.99.1";
  src = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-bLDEt1sKiS6ReQ6Uch0tOSLU8aykKl3UwN7WVkRE9Og=";
  };
  npmDepsHash = "sha256-eKtv1fN7X4ukuYbsj7hduGZ3W2FdmO/fAnoaWJp7MQQ=";
  # Published releases contain the catalog generated at release time.
  # Pin it independently so git builds can also use a stable release catalog.
  modelDataVersion = "0.99.1";
  modelDataHash = "sha256-+fRGkhV9C/VnnEoXMEoxACgjHX2q6q6jtzJS9LeiZNM=";
  modelData = prev.fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${modelDataVersion}.tgz";
    hash = modelDataHash;
  };
in
{
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
    inherit
      version
      src
      npmDepsHash
      modelData
      ;
    preConfigure = ''
      rm -rf packages/ai/src/providers/data
      mkdir -p packages/ai/src/providers/data
      tar --extract --gzip --file=${modelData} \
        --directory=packages/ai/src/providers/data \
        --strip-components=4 \
        package/dist/providers/data
      chmod -R +w packages/ai/src/providers/data
    '';
    passthru = old.passthru // {
      inherit modelData modelDataVersion;
    };
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = npmDepsHash;
    };
    buildPhase = ''
      runHook preBuild

      # Follow upstream's workspace order without fetching model data again.
      npm run build:offline

      runHook postBuild
    '';
    postInstall = ''
      local nm="$out/lib/node_modules/pi-monorepo/node_modules"

      # Replace workspace deps needed at runtime with real copies.
      for ws in @earendil-works/chord:packages/chord \
                @earendil-works/pi-ai:packages/ai \
                @earendil-works/pi-agent-core:packages/agent \
                @earendil-works/pi-client:packages/client \
                @earendil-works/pi-codemode:packages/codemode \
                @earendil-works/pi-durable:packages/durable \
                @earendil-works/pi-mcp:packages/mcp \
                @earendil-works/pi-server:packages/server \
                @earendil-works/pi-session-backend-sqlite-node:packages/session-backends/sqlite-node \
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
    doInstallCheck = prev.lib.hasPrefix "v" src.rev;
    meta = old.meta // {
      homepage = "https://pi.dev/";
      downloadPage = "https://www.npmjs.com/package/@earendil-works/pi-coding-agent";
      changelog = "https://github.com/earendil-works/pi/releases/tag/v${version}";
    };
  });
}
