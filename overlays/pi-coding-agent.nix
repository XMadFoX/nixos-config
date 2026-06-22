final: prev:
let
  version = "0.79.9";
  src = prev.fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-+h1D51JM4F2iHCzTA57A5/uAzHQBKSlz/7x3/PtQhec=";
  };
  npmDepsHash = "sha256-uej0uXVbihmxpuvviCK/5JFSEqDamIW5ETOL/ZKW45g=";
in
{
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
    inherit version src npmDepsHash;
    npmDeps = prev.fetchNpmDeps {
      inherit src;
      hash = npmDepsHash;
    };
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
