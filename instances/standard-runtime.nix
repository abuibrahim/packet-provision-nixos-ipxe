{ config, lib, pkgs, ... }:
let
  testbed = pkgs.haskellPackages.callPackage
    ({ mkDerivation, stdenv, fetchFromGitHub, base, hxt, libvirt-hs }:
      mkDerivation rec {
        pname = "testbed";
        version = "1.0.0";
        src = fetchFromGitHub {
          owner = "abuibrahim";
          repo = "testbed";
          rev = "v${version}";
          sha256 = "0917prncd7a8pjywkqgdzgslynsn3hvkr0sgxr8pr32vhnkp82cr";
        };
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [ base hxt libvirt-hs ];
        description = "Libvirt helper for creating arbitrary network topologies";
        license = stdenv.lib.licenses.isc;
        maintainers = [ stdenv.lib.maintainers.abuibrahim ];
    }) {};
in
{
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    wget tmux vim htop git gnumake testbed cdrkit openssl
  ];

  networking = {
    nat = {
      enable = true;
      externalInterface = "bond0";
      internalIPs = [ "10.0.0.0/8" ];
      forwardPorts = [
        { sourcePort = 443; destination = "10.1.0.14:443"; }
      ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 443 ];
    };
  };
}
