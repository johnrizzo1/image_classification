{
  description = "Image Classification with Tensorflow";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, devenv-root, devenv, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
        packages.default = self'.devShells.default;

        devenv.shells.default = {
          devenv.root =
            let
              devenvRootFileContent = builtins.readFile devenv-root.outPath;
            in
            lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          name = "image_classification";
          imports = [
            # This is just like the imports in devenv.nix.
            # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            # ./devenv-foo.nix
          ];

          # https://devenv.sh/reference/options/
          packages = with pkgs; [
            # config.packages.default
            git # Code management
            jq # Query JSON
            yq # Query YAML
            wget
            curl
            portaudio
            ffmpeg
          ] ++ lib.optionals pkgs.stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.SystemConfiguration
          ] ++ lib.optionals pkgs.stdenv.isLinux [ ];

          # Python setup
          languages.python.enable = true;
          languages.python.venv.enable = true;
          languages.python.uv.enable = true;
          languages.python.poetry.enable = true;

          difftastic.enable = true;
          dotenv.enable = true;

          cachix.enable = true;
          cachix.pull = [ "pre-commit-hooks" ];

          enterShell = ''
            echo "Welcome to the nix ai/ml/ds toolkit"
            echo '-----------------------------------'
            echo -n 'Git:    '; git --version
            echo -n 'Python: '; python --version
          '';
        };
      };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
