{
  config,
  lib,
  dream2nix,
  ...
}: let
  pyproject = lib.importTOML (config.mkDerivation.src + /pyproject.toml);
in {
  imports = [
    dream2nix.modules.dream2nix.pip
    dream2nix.modules.dream2nix.flags
  ];

  deps = {
    nixpkgs,
    self,
    ...
  }: {
    stdenv = nixpkgs.stdenv;
    python = nixpkgs.python312;
    python312Packages.hatchling = nixpkgs.python312Packages.hatchling;
  };

  flagsOffered = {
    extraRabbit = "include dependencies for optional [rabbit] pip extras";
    extraKafka = "include dependencies for optional [kafka] pip extras";
    extraConfluent = "include dependencies for optional [confluent] pip extras";
    extraNats = "include dependencies for optional [nats] pip extras";
    extraRedis = "include dependencies for optional [redis] pip extras";
    extraOtel = "include dependencies for optional [otel] pip extras";
    extraDev = "include dependencies for optional [dev] pip extras";
    extraTesting = "include dependencies for optional [testing] pip extras";
    pipFlattenDependencies = "flatten dependencies";
  };

  flags = {
    extraRabbit = lib.mkDefault false;
    extraKafka = lib.mkDefault false;
    extraConfluent = lib.mkDefault false;
    extraNats = lib.mkDefault false;
    extraRedis = lib.mkDefault false;
    extraOtel = lib.mkDefault false;
    extraDev = lib.mkDefault false;
    extraTesting = lib.mkDefault false;
    pipFlattenDependencies = lib.mkDefault false;
  };

  inherit (pyproject.project) name;
  version = "0.5.14";

  mkDerivation = {
    src = ./.;
    nativeBuildInputs = [
      config.deps.python312Packages.hatchling
    ];
    buildInputs = [
      config.deps.python
      config.deps.python312Packages.hatchling
    ];
  };

  buildPythonPackage = {
    format = lib.mkForce "pyproject";
  };

  pip = {
    requirementsList =
      pyproject.build-system.requires
      or []
      ++ pyproject.project.dependencies
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.dev
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.optionals
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.rabbit
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.kafka
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.confluent
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.nats
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.redis
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.otel
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.lint
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.types
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.testing
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.test-core
      ++ lib.optionals (config.flags.extraDev) pyproject.project.optional-dependencies.devdocs;
    flattenDependencies = config.flags.pipFlattenDependencies;
    overrideAll.deps.python = lib.mkForce config.deps.python;
    overrides = {
      # dream2nix cannot automatically resolve this dependency because it uses dynamic
      # hidden imports. Explicitly defining it here and in pyproject.toml makes it available
      hatchling.mkDerivation = {};
    };
  };
}
