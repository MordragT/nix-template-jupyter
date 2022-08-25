{
  description = "JupyterLab Flake";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    jupyterWith.url = "github:tweag/jupyterWith";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, jupyterWith, fenix }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
        };
        python = pkgs.kernels.iPythonWith {
          name = "python";
          packages = p: with p; [ pandas ];
        };
        rust = pkgs.kernels.rustWith {
          name = "rust";
          packages = with pkgs; [
            openssl
            pkgconfig
            # todo switch when jupyterWith deploys rewrite
            # to fix rust-src issues
            # 
            # (with fenix.packages.${system}.complete; [
            #   cargo
            #   rustc
            #   rust-src
            #   clippy
            #   rustfmt
            # ])
          ];
        };
        js = pkgs.kernels.iJavascript {
          name = "js";
        };
        c = pkgs.kernels.cKernelWith {
          name = "c";
        };
        jupyterEnv = pkgs.jupyterlabWith {
          kernels = [ python rust js c ];
          extraPackages = p: with p; [
            pandoc
            tectonic
            biber
          ];
        };
      in
      {
        devShell = jupyterEnv.env;
      }
    );
}
