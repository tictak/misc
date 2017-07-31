set -x
for arg in "$@"
do
	[ -z $clear ] && set --  && clear=yes
	case "$arg" in
		--help)    set -- "$@" -h ;;
		--verbose) set -- "$@" -v ;;
		--config)  set -- "$@" -c ;;
		--file*)   set -- "$@" -f ${arg#--file=};;
		*)         set -- "$@" "$arg" ;;
	esac
done

vflag=off
filename=
while getopts vf: opt
do
	echo $OPTIND
	case "$opt" in
		v)  vflag=on;;
		f)  filename="$OPTARG";;
		\?)		# unknown flag
			echo >&2  "usage: $0 [-v] [-f filename] [file ...]"
			exit 1;;
	esac
done
shift $((OPTIND - 1))
echo $vflag
echo $filename
