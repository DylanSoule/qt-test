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
      ];

      shellHook = ''
        code .
      '';
    };
  };
}
