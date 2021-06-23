# Source: https://davidverhasselt.com/zenity-rsync-and-awk/
{
	if (index($0, "to-chk=") > 0) {
		split($0, pieces, "to-chk=")
		split(pieces[2], term, ")");
		split(term[1], division, "/");
		if (length(total) == 0) {
			total=division[1]
		}
		print (1-(division[1]/total))*100"%"
	} else {
		print "#"A[split($0,A,"\r")];
	}
	fflush();
}
