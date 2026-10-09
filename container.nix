# OCI image serving a site with bun + vite.
{
  lib,
  dockerTools,
  site,
  name ? "test-website",
  tag ? "latest",
  port ? "3000",
  ...
}:
dockerTools.buildLayeredImage {
  inherit name;
  inherit tag;

  # Defaults to "scratch" image
  fromImage = null;

  config = {
    Entrypoint = [
      (lib.getExe site)
    ];
    ExposedPorts = { "${port}/tcp" = { }; };
  };
}
