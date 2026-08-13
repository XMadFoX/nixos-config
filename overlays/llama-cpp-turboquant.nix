final: prev:
let
  rev = "fca3093c9e6544476bbb2a139a25e17dd63627e1";

  forkedLlamaCpp = prev.llama-cpp.overrideAttrs (_old: {
    version = "10465";

    src = prev.fetchFromGitHub {
      owner = "TheTom";
      repo = "llama-cpp-turboquant";
      inherit rev;
      hash = "sha256-zrLzRA73d6I04x0fWGGiA8UsMqtIbPhVKp7juvnYjvI=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    npmRoot = "tools/ui";
    npmDepsHash = "sha256-FHvd2bMvBc9EXrJEzu8EN78oUVSLcOKYCc0232V+L4A=";

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
