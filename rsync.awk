# Source: https://davidverhasselt.com/zenity-rsync-and-awk/
{
	if (index($0, "to-chk=") > 0) {
		split($0, pieces, "to-chk=")
		split(pieces[2], term, ")");
		split(term[1], division, "/");
		print (1-(division[1]/division[2]))*100"%"
	} else {
		print "#"$0;
	}
	fflush();
}
