a=b
b=c

echo ${!a}

echo ${!a*}

d=(nihao wohao)
echo ${!d[@]}
echo ${d[@]}
echo ${#d[@]}
