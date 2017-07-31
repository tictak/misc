set  "1 2" 3 4


for i in "ni $@ wo"
do
	echo word $i
done

for i in "ni wo ta"
do
	echo  $i
done

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
