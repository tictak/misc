set  "1 2" 3 4

echo '"$@":'
for arg in "$@" 
do
	echo $arg
done
echo

echo '$@:'
for arg in $@
do
	echo $arg
done
echo

echo '"$*":'
for arg in "$*"
do
	echo $arg
done
echo

echo '$*:'
for arg in $*
do
	echo $arg
done
