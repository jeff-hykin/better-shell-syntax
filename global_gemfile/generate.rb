#!/usr/bin/env ruby

# File   : generate.rb
# Author : derkallevombau
# Date   : Apr 11, 2020

# Create a global Gemfile in the user's home dir by inserting the :vscode_ext_deps_ruby group
# from this project's Gemfile into the template.

Dir.chdir(__dir__)

## Extract gem lines of :vscode_ext_deps_ruby group in project's Gemfile.

inGroup       = false
groupGemLines = []

File.foreach('../Gemfile') do |line|
	if !inGroup && line =~ /^group\(:vscode_ext_deps_ruby/
		inGroup = true
		next
	elsif !inGroup
		next
	elsif line =~ /^end/ # We know that inGroup == true here.
		break
	end

	groupGemLines.push(line) if line =~ /^\s*gem/
end

## Read the template file lines into an array and insert the :vscode_ext_deps_ruby group.

# @type [Array<String>]
globalGemfileLines = File.readlines('Gemfile.template')

insertAt = globalGemfileLines.index { |line| line =~ /^ruby/ } + 1 # Insert after Ruby version specification.

globalGemfileLines.insert(insertAt,
	"\n",
	"group(:vscode_ext_deps_ruby) do\n",
	*groupGemLines,
	"end\n"
)

## Write result to ~/Gemfile.

globalGemfile = File.join(Dir.home, 'Gemfile')

# Check if outFile already exists and rename it, if any.

if File.exist?(globalGemfile)
	globalGemfileBak = globalGemfile + '.bak'

	if File.rename(globalGemfile, globalGemfileBak)
		puts("Info: Renamed already existing file '#{globalGemfile}' to '#{globalGemfileBak}'.")
	else
		raise("Error: Failed to rename already existing file '#{globalGemfile}' to '#{globalGemfileBak}', aborting.")
	end
end

bytesWritten = File.write(globalGemfile, globalGemfileLines.join(''))

puts("Wrote #{bytesWritten} bytes to '#{globalGemfile}'.")
