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
        xorg.xcbutilwm
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil
        xorg.libX11
        xorg.libxcb
        xorg.libXcursor
        xorg.libXi
        xorg.libXrender
        xorg.libXrandr
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

        qt6.qtbase
        qt6Combined
        qt6.wrapQtAppsHook
      ] ++ runtimeLibs;

      shellHook = ''
        # Override host QT_PLUGIN_PATH so system KDE/Qt plugins do not interfere
        export QT_PLUGIN_PATH="${qt6Combined}/lib/qt-6/plugins"

        # Provide runtime library lookup path for dlopen calls inside Qt platform plugins
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"

        code .
      '';
    };
  };
}
