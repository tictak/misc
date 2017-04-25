#https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
#https://www.gnu.org/software/gawk/manual/html_node/Gory-Details.html#Gory-Details

awk '{ sub(/candidate/, "& and his wife"); print } ' <<< candidate

awk ' BEGIN { 
	a = "abc def" 
	b = gensub(/(.+) (.+)/, "\\2 \\1", "g", a) 
	print b
 }' -
