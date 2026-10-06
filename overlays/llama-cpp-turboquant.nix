final: prev:
let
  rev = "4deec5587b2963af00bdf80884f3337e02eb7d64";

  forkedLlamaCpp = prev.llama-cpp.overrideAttrs (_old: {
    version = "10760";

    src = prev.fetchFromGitHub {
      owner = "TheTom";
      repo = "llama-cpp-turboquant";
      inherit rev;
      hash = "sha256-whsDvnFbJZf7cpLGfH480PnZSzJ2AmjsZSZtGMgTNt8=";
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
      # HIP-only D=512 VEC FA instantiations overflow CUDA ptxas shared memory
      # (0x10100 vs 48 KiB) even when targeting sm_120a-real.
      sed -i '/DECL_FATTN_VEC_CASE_D512/d' ggml/src/ggml-cuda/template-instances/fattn-vec-instance-*.cu
      sed -i '/^[[:space:]]*FATTN_VEC_CASE_D512(/d' ggml/src/ggml-cuda/fattn.cu
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
          # 120a-real (no virtual PTX) is required: D=512 turbo VEC FA kernels
          # use ~64 KiB static smem, which ptxas rejects for compute_120a (48 KiB cap).
          ++ [ "-DCMAKE_CUDA_ARCHITECTURES:STRING=120a-real" ];
      });
in
{
  llama-cpp = forkedLlamaCpp;
  llama-cpp-cuda = forkedLlamaCppCuda;
  llama-cpp-turboquant = forkedLlamaCpp;
  llama-cpp-turboquant-cuda = forkedLlamaCppCuda;
}
