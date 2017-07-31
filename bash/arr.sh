declare -A worklist

a="a"
b="b"
worklist[ipnet]="$a><$b"


for i  in ${!worklist[@]} 
do
	echo ${worklist[$i]#*><}
	echo ${worklist[$i]%><*}
done
