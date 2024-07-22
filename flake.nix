{
    outputs = { self, nixpkgs }:
        let
        # The systems supported for this flake
        supportedSystems = [
            "x86_64-linux" # 64-bit Intel/AMD Linux
            "aarch64-linux" # 64-bit ARM Linux
            "x86_64-darwin" # 64-bit Intel macOS
            "aarch64-darwin" # 64-bit ARM macOS
            "powerpc64le-linux"
        ];

        forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
            pkgs = import nixpkgs { inherit system; };
        });
        in {
            devShells = forEachSupportedSystem ({ pkgs }: 
                let py = pkgs.python312; 
                    env = (import ./requirements.nix) {
                        buildPythonPackage = py.pkgs.buildPythonPackage;
                        fetchurl = pkgs.fetchurl;
                    };
                    pythonEnv = py.withPackages(
                        ps: env.env
                    );
                in {
                default = pkgs.mkShell {
                    packages = with pkgs; [ pythonEnv fish ];
                    shellHook = ''
                    exec fish
                    '';
                };
            });
        };
}