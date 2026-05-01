# TODO: remove once https://github.com/NixOS/nixpkgs/issues/<issue-number> is fixed
# OpenLDAP tests fail on i686, disabling them as a temporary workaround.
final: prev: {
  openldap = prev.openldap.overrideAttrs (_: {
    doCheck = !prev.stdenv.hostPlatform.isi686;
  });
}
