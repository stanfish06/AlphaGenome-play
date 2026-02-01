{
  description = "dev shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      python = pkgs.python312;
      alphagenome = python.pkgs.buildPythonPackage rec {
        pname = "alphagenome";
        version = "0.5.1";
        format = "other";

        src = python.pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-58oh3LQx/6Ui1vkRrnl51fHh72PGISRNHgDbh174cDs=";
        };

        nativeBuildInputs = with python.pkgs; [
          setuptools
          wheel
          pip
          flit
          hatchling
        ];

        buildPhase = ''
          runHook preBuild
          export PYTHONPATH="${python.pkgs.setuptools}/${python.sitePackages}:${python.pkgs.wheel}/${python.sitePackages}:${python.pkgs.pip}/${python.sitePackages}:${python.pkgs.flit}/${python.sitePackages}/${python.pkgs.hatchling}/${python.sitePackages}:$PYTHONPATH"
          ${python}/bin/python -m pip wheel --no-deps --no-build-isolation --wheel-dir dist .
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          export PYTHONPATH="${python.pkgs.pip}/${python.sitePackages}:$PYTHONPATH"
          ${python}/bin/python -m pip install dist/*.whl --no-deps --prefix=$out
          runHook postInstall
        '';

        propagatedBuildInputs = with python.pkgs; [ grpcio-tools ];
        doCheck = false;
      };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [
            (python.withPackages (
              ps: with ps; [
                numpy
                pandas
                scanpy
                scipy
                seaborn
                matplotlib
                statsmodels
                jupyterlab
                jupyterlab-vim
                marimo
                networkx
                alphagenome
                immutabledict
                ml-dtypes
                zstandard
                jaxtyping
                typeguard
                absl-py
                intervaltree
                plotnine
                pyarrow
              ]
            ))
          ];
        };
      };
    };
}
