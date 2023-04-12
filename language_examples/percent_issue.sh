echo %
echo %{url_effective}

blah_2="$(echo "$blah_2" | curl -Gso /dev/null -w %{url_effective} @- "" | cut -c 3- )"
