# I) Recommended way to install the dependencies
#
#    1. Execute global_gemfile/generate.rb.
#       This will create a Gemfile in your home dir.
#       Follow the instructions in that file.
#       This will install bundler and the gems from the :vscode_ext_deps_ruby group in ~/.gem.
#
#    2. Execute 'bundle install' in the project's root dir.
#       This will install the runtime dependencies to .bundle.
#
#       Note: In .bundle/config, path is set to '.bundle' to use a separate
#             gems dir for each project, analogously to npm.
#             If you use a common gems dir and execute 'bundle clean' after
#             removing a gem from your Gemfile, it will wipe out everything
#             that is not listed in Gemfile.lock in the cwd because it has
#             no knowledge of your other projects' Gemfiles.
#
# II) If you don't want to work on other Ruby projects and want to start right away,
#     just execute 'bundle install'.
#     This will install everything to .bundle in the project's root dir.
#     Be sure to configure the extensions to use bundler as stated in
#     .vscode/extensions.json.

source('https://rubygems.org')

ruby('2.7.0')

group(:vscode_ext_deps_ruby, optional: true) do
	gem('solargraph')            # Required by VS Code Extension 'castwide.solargraph'. Includes rubocop. See .vscode/extensions.json.
	gem('rubocop-require_tools') # Plugin for rubocop, checks for missing requires.
	gem('ruby-debug-ide')        # Required by VS Code Extension 'rebornix.ruby' for debugging Ruby scripts. See .vscode/extensions.json.
	gem('debase')                # Required by ruby-debug-ide.
end

# Runtime dependencies (:default group; I think you can regard this as bundler's equivalent to npm's "dependencies")
gem('deep_clone')
