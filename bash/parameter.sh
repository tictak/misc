
echo ${BASH_SOURCE}
echo $0
dirname `readlink -f "$0"`

a=b
b=c

echo ${!a}

echo ${!a*}

d=(nihao wohao)
echo ${!d[@]}
echo ${d[@]}
echo ${#d[@]}
