source('https://rubygems.org')

ruby('2.7.0')

# In :default group (I think you can regard this as bundler's equivalent to npm's "dependencies")
gem('deep_clone')

group :vscode do
	gem('solargraph')            # Required by VS Code Extension 'castwide.solargraph'. Includes rubocop. See .vscode/extensions.json.
	gem('rubocop-require_tools') # Plugin for rubocop, checks for missing requires.
	gem('ruby-debug-ide')        # Required by VS Code Extension 'rebornix.ruby' for debugging Ruby scripts. See .vscode/extensions.json.
	gem('debase')                # Required by ruby-debug-ide.
end

# In .bundle/config, path is set to '.bundle' to use a separate
# gems dir for each project, analogously to npm.
# If you use a common gems dir and execute 'bundle clean' after
# removing a gem from your Gemfile, it will wipe out everything
# that is not listed in Gemfile.lock in the cwd because it has
# no knowledge of your other projects' Gemfiles.
