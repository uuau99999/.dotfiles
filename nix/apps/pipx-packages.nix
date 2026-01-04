# pipx-packages.nix
# Declarative configuration for Python tools installed via `pipx install`
#
# Usage: Add packages to the pipxPackages list below.
# Packages will be installed automatically during `home-manager switch`.
#
# Supported formats:
#   - Simple: "package-name"
#   - With inject: { name = "package-name"; inject = [ "dep1" "dep2" ]; }
#   - With options: { name = "package-name"; inject = [ "dep1" ]; includeApps = true; }

{ pkgs, lib, config, ... }:

let
  pipx = pkgs.pipx;
  # List of packages to install via `pipx install`
  # These are typically Python CLI tools that should be globally available
  pipxPackages = [
    # Build Tools
    # "poetry"
    # "pdm"
    # "hatch"

    # Development Tools
    # "cookiecutter"
    # "pre-commit"

    # CLI Tools
    # "httpie"
    # "youtube-dl"

    # Example with inject:
    # {
    #   name = "ipython";
    #   inject = [ "numpy" "pandas" ];
    #   includeApps = false;  # optional, adds --include-apps flag
    # }

    # Add your packages here...
    {
      name ="sqlit-tui";
      inject = [ "psycopg2-binary" ];
    }
    "pgcli"
  ];

  # Helper function to normalize package spec
  normalizePackage = pkg:
    if builtins.isString pkg then {
      name = pkg;
      inject = [];
      includeApps = false;
    } else {
      name = pkg.name;
      inject = pkg.inject or [];
      includeApps = pkg.includeApps or false;
    };

  # Normalize all packages
  normalizedPackages = map normalizePackage pipxPackages;

  # Generate install commands for a package
  genInstallScript = pkg: ''
    # Check if venv is broken (missing python executable)
    VENV_PYTHON="$HOME/.local/pipx/venvs/${pkg.name}/bin/python"
    NEED_INSTALL=false

    if ! echo "$INSTALLED_PKGS" | grep -qx "${pkg.name}"; then
      NEED_INSTALL=true
    elif [ ! -x "$VENV_PYTHON" ]; then
      echo "Broken venv detected for ${pkg.name}, reinstalling..."
      run $PIPX_CMD uninstall --yes "${pkg.name}" 2>/dev/null || true
      NEED_INSTALL=true
    fi

    if [ "$NEED_INSTALL" = true ]; then
      echo "Installing ${pkg.name} via pipx..."
      run $PIPX_CMD install "${pkg.name}"
    else
      echo "${pkg.name} is already installed"
    fi
  '' + lib.optionalString (pkg.inject != []) ''
    # Inject dependencies into ${pkg.name}
    echo "Injecting dependencies into ${pkg.name}..."
    run $PIPX_CMD inject ${lib.optionalString pkg.includeApps "--include-apps "}${pkg.name} ${lib.concatStringsSep " " pkg.inject}
  '';
in
{
  home.activation.installPipxPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Only proceed if there are packages to install
    if [ ${toString (builtins.length pipxPackages)} -gt 0 ]; then
      # Use pipx installed via home.packages
      PIPX_CMD="${lib.getExe pipx}"

      if [ -x "$PIPX_CMD" ]; then
        echo "Syncing pipx packages..."

        # Get list of installed packages
        INSTALLED_PKGS=$($PIPX_CMD list --short 2>/dev/null | awk '{print $1}' || true)

        # Remove broken venvs (pointing to missing Python)
        for pkg in $INSTALLED_PKGS; do
          VENV_PYTHON="$HOME/.local/pipx/venvs/$pkg/bin/python"
          if [ -d "$HOME/.local/pipx/venvs/$pkg" ] && [ ! -e "$VENV_PYTHON" ]; then
            echo "Removing broken venv for $pkg..."
            $PIPX_CMD uninstall --yes "$pkg" 2>/dev/null || rm -rf "$HOME/.local/pipx/venvs/$pkg"
            INSTALLED_PKGS=$(echo "$INSTALLED_PKGS" | grep -v "^$pkg$" || true)
          fi
        done

        ${lib.concatMapStringsSep "\n" genInstallScript normalizedPackages}
      else
        echo "Warning: pipx not found at $PIPX_CMD, skipping pipx packages installation"
      fi
    fi
  '';
}
