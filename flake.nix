{
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        erlangVersion = "erlang_27";
        elixirVersion = "elixir_1_17";

        elixir = pkgs.beam.packages.${erlangVersion}.${elixirVersion};
        erlang = pkgs.beam.interpreters.${erlangVersion};

        python = pkgs.python3;
        pythonPkgs = pkgs.python3Packages;

        node = pkgs.nodejs_22;
      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            elixir
            erlang

            python
            pythonPkgs.mutagen

            node
          ];
          ERL_AFLAGS = "-kernel shell_history enabled";
        };
      }
    );
}
