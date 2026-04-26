final: prev:
let
  version = "0.233.9";
  executableName = "zeditor";

  srcs = {
    x86_64-linux = prev.fetchurl {
      url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
      hash = "sha256-VEiGK4CPfJTewL/dKEppY1+o2+HppnF/WMylRoGnW0A=";
    };
    aarch64-linux = prev.fetchurl {
      url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-aarch64.tar.gz";
      hash = "sha256-f/Gbv6eNWHuc3aXSKc7+zFTZFsLjAoWCOwX+oymTWUU=";
    };
  };

  fhs =
    {
      zed-editor,
      additionalPkgs ? pkgs: [ ],
    }:
    prev.buildFHSEnv {
      name = executableName;

      targetPkgs =
        pkgs:
        (with pkgs; [
          glibc
          openssl
          libcap
          zlib
        ])
        ++ additionalPkgs pkgs;

      extraBwrapArgs = [
        "--bind-try /etc/nixos/ /etc/nixos/"
        "--ro-bind-try /etc/xdg/ /etc/xdg/"
      ];

      extraInstallCommands = ''
        ln -s "${zed-editor}/share" "$out/"
      '';

      runScript = "${zed-editor}/bin/${executableName}";

      passthru = {
        inherit executableName;
        inherit (zed-editor) pname version;
      };

      meta = zed-editor.meta // {
        description = ''
          Wrapped variant of ${zed-editor.pname} which launches in a FHS compatible environment.
          Should allow for easy usage of extensions without nix-specific modifications.
        '';
      };
    };
in
rec {
  zed-editor = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "zed-editor";
    inherit version;

    src = srcs.${prev.stdenv.hostPlatform.system};

    nativeBuildInputs = [
      prev.autoPatchelfHook
      prev.makeBinaryWrapper
      prev.patchelf
    ];

    buildInputs = [
      prev.alsa-lib
      prev.fontconfig
      prev.glib
      prev.libGL
      prev.libxkbcommon
      prev.openssl
      prev.stdenv.cc.cc.lib
      prev.vulkan-loader
      prev.wayland
      prev.libx11
      prev.libxcb
      prev.libxext
      prev.zlib
    ];

    runtimeDependencies = [
      prev.libGL
      prev.libxkbcommon
      prev.vulkan-loader
      prev.wayland
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R . "$out"

      mv "$out/bin/zed" "$out/bin/${executableName}"
      ln -s ${executableName} "$out/bin/zed"

      substituteInPlace "$out/share/applications/dev.zed.Zed.desktop" \
        --replace-fail "Exec=zed" "Exec=${executableName}"

      runHook postInstall
    '';

    postFixup = ''
      runtimeLibPath=${prev.lib.makeLibraryPath [
        prev.libGL
        prev.libxkbcommon
        prev.vulkan-loader
        prev.wayland
      ]}

      patchelf --add-rpath "$runtimeLibPath" "$out/bin/${executableName}"
      patchelf --add-rpath "$runtimeLibPath" "$out/libexec/zed-editor"

      wrapProgram "$out/libexec/zed-editor" \
        --suffix PATH : ${prev.lib.makeBinPath [ prev.nodejs ]}
    '';

    passthru = {
      inherit executableName;
      fhs = fhs { zed-editor = finalAttrs.finalPackage; };
      fhsWithPackages = additionalPkgs: fhs { zed-editor = finalAttrs.finalPackage; inherit additionalPkgs; };
    };

    meta = {
      description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
      homepage = "https://zed.dev";
      changelog = "https://github.com/zed-industries/zed/releases/tag/v${version}";
      license = prev.lib.licenses.gpl3Only;
      mainProgram = executableName;
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  });

  zed-editor-fhs = zed-editor.fhs;
}
