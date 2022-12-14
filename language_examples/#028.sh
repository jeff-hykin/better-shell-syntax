readonly PROFILE_FISH_PREFIXES=(
    # each of these are common values of $__fish_sysconf_dir,
    # under which Fish will look for a file named
    # $PROFILE_FISH_SUFFIX.
    "/etc/fish"              # standard
    "/usr/local/etc/fish"    # their installer .pkg for macOS
    "/opt/homebrew/etc/fish" # homebrew
    "/opt/local/etc/fish"    # macports
)
readonly PROFILE_NIX_FILE_FISH="$NIX_ROOT/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"