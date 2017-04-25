#http://www.shelldorado.com/goodcoding/cmdargs.html
vflag=off
filename=
set -- `getopt vf: "$@"`
[ $# -lt 1 ] && exit 1
while [ $# -gt 0 ]
do
	case "$1" in
		-v) vflag=on;;
		-f) filename="$2" ; shift;;
		--) shift; break;;
		-*)
			echo >&2 "usage: $0 [-v] [-f file] [file...]"
			exit 1;;
		*) break;;
	esac
	shift
done
echo $vflag
echo $filename
