    
    restore_profile() {
        profile="$1"
        
        # check if file exists
        if [ -f "$profile" ]
        then
            if extract_nix_profile_injection "$profile"; then
                # the extraction is done in-place. So if successful, remove the backup
                _sudo rm -f "$profile.backup-before-nix"
            fi
        fi
    }
    