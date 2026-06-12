{
  description = "Cross-platform app for the self-hosted music streaming server Vibin'";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      let
        desktopItem = pkgs.makeDesktopItem {
          name = "vibin";
          exec = "vibin";
          icon = "vibin";
          desktopName = "Vibin'";
          comment = "Self-hosted music streaming client";
          categories = [ "AudioVideo" "Audio" "Music" "Player" ];
        };
      in {
        packages.default = pkgs.flutter.buildFlutterApplication {
          pname = "vibin";
          version = "0.0.1";

          src = ./.;

          targetFlutterPlatform = "linux";

          pubspecLock = pkgs.lib.importJSON ./pubspec.lock.json;

          gitHashes = {};

          runtimeDependencies = [ pkgs.mpv ];

          preBuild = ''
            packageRunCustom build_runner build_runner -- build --delete-conflicting-outputs --verbose
          '';

          postInstall = ''
            cp -r --no-preserve=mode,ownership ${desktopItem}/share $out/share
            install -Dm644 assets/icons/icon.png $out/share/icons/hicolor/256x256/apps/vibin.png
            mv $out/bin/vibin_app $out/bin/vibin
            sed -i "s|Icon=vibin|Icon=$out/share/icons/hicolor/256x256/apps/vibin.png|" $out/share/applications/vibin.desktop
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ flutter pkg-config cmake ninja clang ];
        };
      });
}
