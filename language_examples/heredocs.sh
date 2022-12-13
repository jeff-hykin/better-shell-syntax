if true; then
	cat <<-EOF
		# My script here
	EOF
	
    cat <<-'EOF'
		# My script here
	EOF
    
    cat <<-"EOF"
		# My script here
	EOF
    
    cat <<'EOF'
		# My script here
EOF
    
    cat <<EOF
		# My script here
EOF
fi


echo "here is some $SYNTAX coloring"
cat << EOF > myfile.txt
multiple line
output into
a file
EOF
echo "here is some more $SYNTAX coloring"


echo "here is some $SYNTAX coloring"
	cat <<-EOF > myfile.txt
	multiple line
	output into
	a file
	EOF
echo "here is some more $SYNTAX coloring"