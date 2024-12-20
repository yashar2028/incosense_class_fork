{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.openssl
    pkgs.llvm
    pkgs.cargo-watch
    pkgs.cargo-tarpaulin
    pkgs.cargo-machete
    pkgs.clippy
    pkgs.cloudflared
    pkgs.doctl
    pkgs.gcc
    pkgs.rustfmt
    pkgs.sqlx-cli
    pkgs.cargo-audit
    pkgs.mold
  ]++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.libiconv
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
    pkgs.darwin.CF
    pkgs.darwin.Security
    pkgs.darwin.configd
    pkgs.darwin.dyld
  ];

  # https://devenv.sh/languages/
  languages.rust = {
      enable = true;
      channel = "nightly";
  };

 # https://devenv.sh/services/
  services.postgres = {
    enable = true;
    listen_addresses = "127.0.0.1";
    port = 5432;
    initialScript = "CREATE ROLE postgres SUPERUSER;";
    initialDatabases = [ { name = "newsletter"; } ];
  };

  # https://devenv.sh/processes/
  processes.backend.exec = "cargo build --release && cargo run";

  containers."prod".name = "incosense_class";
  containers."prod".copyToRoot = ./target/release;
  containers."prod".startupCommand = "/incosense_class";


  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    clippy.enable = true;
    clippy.packageOverrides.cargo = pkgs.cargo;
    clippy.packageOverrides.clippy = pkgs.clippy;
    # some hooks provide settings
    clippy.settings.allFeatures = true;
    cargo-check.enable = true;
    rustfmt.enable = true;
  };

  devcontainer.enable = true;
  # See full reference at https://devenv.sh/reference/options/
}
