fields=1,4
columns=
a=(sentry name open yday now high low byp1 slp1 dealn dealp byn1 byp1 byn2 byp2 byn3 byp3 byn4 byp4 byn5 byp5 sln1 slp1 sln2 slp2 sln3 slp3 sln4 slp4 sln5 slp5 date time null)

for arg in "$@"; do
	[ -z $clear ] && set -- && clear=yes
	case "$arg" in
		--column) set -- "$@"  -c ;;
		--field*) set -- "$@"  -f ${arg#--field=};;
		*)	  set -- "$@" "$arg";;
	esac
done

while getopts cf: opt; do
	case $opt in
	       	c) columns=yes;;
		f) fields="$OPTARG";;
		*) echo >&2 "usage $0 [-c] [--column] [-f 1,2,3] [--field=1,2,3]"
		   exit 1;;
	esac

done
if [[ "$columns" ]] ; then
	(for ((i=0;i< ${#a[@]}; i++ )); do
		echo -n "$i "
	done
	echo
	for ((i=0;i< ${#a[@]}; i++ )); do
		echo -n "${a[$i]} "
	done
	echo) | column -t -c 1
	exit 0
fi
title=whatyouwant
awkstr=whatyouwant
while IFS=',' read -a item ; do
	for i in "${item[@]}"; do
		title="$title ,\"${a[$i]}\""
		awkstr="$awkstr ,\$$i"
	done
done <<< "$fields"

curl -s hq.sinajs.cn/list=sh603881,sh603138,sh000001,sz399678 | iconv -f  gbk  -t utf-8 | awk -F'"'  '{print $2}'  | awk -F',' " BEGIN { print $title,\"rate\"} { print $awkstr,int((\$4-\$3)/\$3*10000)/100\"%\"} " | column -t
