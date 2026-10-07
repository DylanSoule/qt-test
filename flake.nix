{
  description = "Dev environment for email client c++ usage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };

      # Group Qt packages into a single unified directory
      qt6Combined = pkgs.symlinkJoin {
        name = "qt6-combined";
        paths = with pkgs.qt6; [
          qtbase
          qttools
          qtwayland
        ];
      };

      # Complete set of runtime libraries needed by Qt 6 platform plugins (X11/Wayland/OpenGL)
      runtimeLibs = with pkgs; [
        libxcb-cursor
        libxcb-wm
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libx11
        libxcb
        libxcursor
        libxi
        libxrender
        libxrandr
        libxkbcommon
        wayland
        libglvnd
        vulkan-loader
        fontconfig
        freetype
        dbus
      ];
    in pkgs.mkShell {
      packages = with pkgs; [
        gcc
        gdb
        ninja
        cmake
        pkg-config
        curl
        vmime

        # Use qt6Combined exclusively so CMake and VS Code find designer in Qt6_DIR
        qt6Combined
      ] ++ runtimeLibs;

      shellHook = ''
        # Create/update a stable local symlink pointing to the combined Qt package
        ln -sfn ${qt6Combined} .nix-qt

        export QT_PLUGIN_PATH="${qt6Combined}/lib/qt-6/plugins"
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"

        if [ "$TERM_PROGRAM" != "vscode" ]; then
          code .
        fi
      '';
    };
  };
}
