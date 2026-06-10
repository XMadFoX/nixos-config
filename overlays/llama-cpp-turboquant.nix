final: prev:
let
  rev = "73eb521daebc85da7c91d37178940b99a5524cf6";

  forkedLlamaCpp = prev.llama-cpp.overrideAttrs (_old: {
    version = "9450";

    src = prev.fetchFromGitHub {
      owner = "TheTom";
      repo = "llama-cpp-turboquant";
      inherit rev;
      hash = "sha256-6tQBZntWSZNYiDjIjyn32tB3AjUTGXkdgfmV0Rdwx2U=";
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

  forkedLlamaCppCuda =
    (forkedLlamaCpp.override {
      cudaSupport = true;
    }).overrideAttrs
      (old: {
        # The default nixpkgs CUDA arch list builds a very large fat binary
        # (75;80;86;89;90;100;103;120;121).  With turboquant's extra CUDA
        # kernels this overflows x86-64 linker relocation ranges while linking
        # libggml-cuda.so.  This host has an RTX 5060 Ti (SM 12.0), so build only
        # the needed Blackwell target.
        cmakeFlags =
          builtins.filter (flag: !(prev.lib.hasPrefix "-DCMAKE_CUDA_ARCHITECTURES" flag)) old.cmakeFlags
          ++ [ "-DCMAKE_CUDA_ARCHITECTURES:STRING=120" ];
      });
in
{
  llama-cpp = forkedLlamaCpp;
  llama-cpp-cuda = forkedLlamaCppCuda;
  llama-cpp-turboquant = forkedLlamaCpp;
  llama-cpp-turboquant-cuda = forkedLlamaCppCuda;
}
