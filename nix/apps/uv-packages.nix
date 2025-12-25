# uv-packages.nix
# Declarative configuration for Python tools installed via `uv tool install`
#
# Usage: Add package names to the uvPackages list below.
# Packages will be installed automatically during `home-manager switch`.

{ pkgs, lib, ... }:

let
  # List of packages to install via `uv tool install`
  # These are typically Python CLI tools that should be globally available
  uvPackages = [
    # Linters & Formatters
    # "ruff"
    # "black"
    # "isort"

    # Type Checkers
    # "mypy"
    # "pyright"

    # Development Tools
    # "ipython"
    # "httpie"
    # "cookiecutter"

    # Add your packages here...
  ];
in
{
  home.activation.installUvPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Only proceed if there are packages to install
    if [ ${toString (builtins.length uvPackages)} -gt 0 ]; then
      # Ensure uv is available (installed via homebrew in darwin.nix)
      # Check common paths for uv
      UV_CMD=""
      if command -v uv &> /dev/null; then
        UV_CMD="uv"
      elif [ -x "/opt/homebrew/bin/uv" ]; then
        UV_CMD="/opt/homebrew/bin/uv"
      elif [ -x "/usr/local/bin/uv" ]; then
        UV_CMD="/usr/local/bin/uv"
      fi

      if [ -n "$UV_CMD" ]; then
        echo "Syncing uv tool packages..."

        # Get list of installed tools (filter out warnings)
        INSTALLED_TOOLS=$($UV_CMD tool list 2>&1 | grep -v "^warning:" | grep -v "^hint:" | awk '{print $1}' || true)

        for pkg in ${lib.concatStringsSep " " uvPackages}; do
          # Check if package is already installed
          if ! echo "$INSTALLED_TOOLS" | grep -qx "$pkg"; then
            echo "Installing $pkg via uv tool..."
            run $UV_CMD tool install "$pkg"
          else
            echo "$pkg is already installed"
          fi
        done
      else
        echo "Warning: uv not found, skipping uv tool packages installation"
      fi
    fi
  '';
}
