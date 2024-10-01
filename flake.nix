{
  description = "A nix flake for a container that will run a dotnet application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      # Replace this with your local binary path
      localBinary = ./hello_world/bin/Release/net7.0/publish;
    in
    pkgs.dockerTools.buildImage {
      name = "dotnet_nix";
      tag = "latest";
      copyToRoot = [ 
        pkgs.bashInteractive
        pkgs.coreutils-full
        pkgs.dotnetCorePackages.runtime_7_0
        pkgs.shadow
      ];
      runAsRoot = ''
        #!${pkgs.runtimeShell}
        mkdir -p /app
        mkdir -p /usr/share
        cp -r ${localBinary}/* /app/
        ln -s ${pkgs.dotnetCorePackages.runtime_7_0} /usr/share/dotnet
      '';
      config = {
        WorkingDir = "/app";
        Cmd = [ "/usr/share/dotnet/dotnet" "hello_world.dll" ];
        # Cmd = [ "tail" "-f" "/dev/null" ];
        ExposedPorts = {
          "7008/tcp" = {};
        };
      };
    };
  };
}
