unsetup_profiles() {
	extract_nix_profile_injection() {
		profile="$1"
		start_line_number="$(cat "$profile" | grep -n "$PROFILE_NIX_START_DELIMETER"'$' | cut -f1 -d: | head -n1)"
		end_line_number="$(cat "$profile" | grep -n "$PROFILE_NIX_END_DELIMETER"'$' | cut -f1 -d: | head -n1)"
		if [ -n "$start_line_number" ] && [ -n "$end_line_number" ]; then
			if [ $start_line_number -gt $end_line_number ]; then
				line_number_before=$(( $start_line_number - 1 ))
				line_number_after=$(( $end_line_number + 1))
				new_top_half="$(head -n$line_number_before)
				"
				new_profile="$new_top_half$(tail -n "+$line_number_after")"
				# overwrite existing profile, but with only Nix removed
				echo "$new_profile" | _sudo tee "$profile" 1>/dev/null
				return 0
			else 
				echo "Something is really messed up with your $profile file"
				echo "I think you need to manually edit it to remove everything related to Nix"
				return 1
			fi
		elif [ -n "$start_line_number" ] || [ -n "$end_line_number" ]; then
		then
			echo "Something is really messed up with your $profile file"
			echo "I think you need to manually edit it to remove everything related to Nix"
			return 1
		fi
	}
	
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
	
	for profile_target in "${PROFILE_TARGETS[@]}"; do
		restore_profile "$profile_target"
	done
}