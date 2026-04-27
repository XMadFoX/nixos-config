final: prev:
let
  rev = "1073622985bb68075472474b4b0fdfcdabcfc9d0";

  forkedLlamaCpp = prev.llama-cpp.overrideAttrs (_old: {
    version = "1073622";

    src = prev.fetchFromGitHub {
      owner = "TheTom";
      repo = "llama-cpp-turboquant";
      inherit rev;
      hash = "sha256-ruXvhD/kvcckZBNTuTcx9Kg6PW5l4lerPcmtP4GeF4k=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    npmDepsHash = "sha256-RAFtsbBGBjteCt5yXhrmHL39rIDJMCFBETgzId2eRRk=";

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
