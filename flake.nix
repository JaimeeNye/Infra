{
  description = "A flake for infra project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in
    {
      devShell.x86_64-linux =
        pkgs.mkShell {
          buildInputs = with pkgs;
            [
              ansible
              sshpass
              # Might be needed for non-NixOS users
              glibcLocales
              terraform
            ];
        };
    };

}
