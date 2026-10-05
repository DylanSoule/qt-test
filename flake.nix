{
  description = "Dev environment for email client c++ usage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self , nixpkgs ,... }: let
    # system should match the system you are running on
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };

      qt6Combined = pkgs.symlinkJoin {
	name = "qt6-combined";
	paths = with pkgs.qt6; [
	  qtbase
	  qttools
	  qtwayland
	];
      };
    in pkgs.mkShell {
      # include necessary packages 
      packages = with pkgs; [
        gcc
	gdb
	gnumake
	cmake

	# Libraries
        curl
        vmime

	# qt6
	qt6.qtbase
	qt6Combined
	qt6.wrapQtAppsHook

	# runtime libraries for qt
	xorg.xcbutilcursor
        libxkbcommon
      ];

      shellHook = ''
	export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
          pkgs.xorg.xcbutilcursor
          pkgs.libxkbcommon
          pkgs.wayland
        ]}:$LD_LIBRARY_PATH"

        code .
      '';
    };
  };
}
