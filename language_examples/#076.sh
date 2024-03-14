read -r -d '' env_ruby <<'=cut'
    require 'yaml'

    input=STDIN.readlines.join
    # default to UTF-8 for the dbs sake
    env = {'LANG' => 'en_US.UTF-8'}
    input.split('_FILE_SEPERATOR_').each do |yml|
       yml.strip!
       begin
         env.merge!(YAML.load(yml)['env'] || {})
       rescue Psych::SyntaxError => e
        puts e
        puts "*ERROR."
       rescue => e
        puts yml
        p e
       end
    end
    env.each{|k,v| puts "*ERROR." if v.is_a?(Hash)}
    puts env.map{|k,v| "-e\n#{k}=#{v}" }.join("\n")
=cut

read -r -d '' env_ruby <<'=cut' | echo 'hello'
    require 'yaml'

    input=STDIN.readlines.join
    # default to UTF-8 for the dbs sake
    env = {'LANG' => 'en_US.UTF-8'}
    input.split('_FILE_SEPERATOR_').each do |yml|
       yml.strip!
       begin
         env.merge!(YAML.load(yml)['env'] || {})
       rescue Psych::SyntaxError => e
        puts e
        puts "*ERROR."
       rescue => e
        puts yml
        p e
       end
    end
    env.each{|k,v| puts "*ERROR." if v.is_a?(Hash)}
    puts env.map{|k,v| "-e\n#{k}=#{v}" }.join("\n")
=cut

howdy