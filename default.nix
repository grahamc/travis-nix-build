{ pkgs ? import <nixpkgs> {} }:
{
  foo = pkgs.stdenv.mkDerivation {
    name = "foo";

    srcs = [
      ./dobuilds.sh
      ./remote.sh
    ];
  };

  bar = pkgs.stdenv.mkDerivation {
    name = "bar";

    srcs = [
      ./dobuilds.sh
      ./remote.sh
    ];

    unpackPhase = ":";

    installPhase = ''
      echo ":)" > $out
    '';
  };

}
