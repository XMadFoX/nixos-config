final: prev:
let
  rev = "2cbfdc62a1a047b01377948dfdede8cb6a744866";

  forkedLlamaCpp = prev.llama-cpp.overrideAttrs (_old: {
    version = "9418";

    src = prev.fetchFromGitHub {
      owner = "TheTom";
      repo = "llama-cpp-turboquant";
      inherit rev;
      hash = "sha256-tXwxGskE8Ao7oozPFhWYPFIUnMN2DC2Q3G29INoVvR8=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    npmRoot = "tools/ui";
    npmDepsHash = "sha256-WaEePrEZ7O/7deP2KJhe0AwiSKYA8HOqETmMHUkmBe0=";

    postPatch = ''
      rm -f tools/server/public/index.html.gz
    '';

    # Keep the machine responsive during local builds.
    CMAKE_BUILD_PARALLEL_LEVEL = "4";
    NINJAFLAGS = "-j4 -l4";
    NIX_BUILD_CORES = "4";
  });

  forkedLlamaCppCuda = forkedLlamaCpp.override {
    cudaSupport = true;
  };
in
{
  llama-cpp = forkedLlamaCpp;
  llama-cpp-cuda = forkedLlamaCppCuda;
  llama-cpp-turboquant = forkedLlamaCpp;
  llama-cpp-turboquant-cuda = forkedLlamaCppCuda;
}
