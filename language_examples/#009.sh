[[ "text" -regex-match '^a([^a]+)a([^a]+)a' ]];
[[ "text" =~           '^a([^a]+)a([^a]+)a' ]];

[[ $var -regex-match '^a([^a]+)a([^a]+)a' ]];
[[ $var =~           '^a([^a]+)a([^a]+)a' ]];

[[ $desc -regex-match '^alias for --(\S+)' ]];
[[ $desc =~           '^alias for --(\S+)' ]];