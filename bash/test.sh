#http://stackoverflow.com/questions/3869072/test-for-non-zero-length-string-in-bash-n-var-or-var
		     1a    2a    3a    4a    5a    6a    |1b    2b    3b    4b    5b    6b
		     [     ["    [-n   [-n"  [-z   [-z"  |[[    [["   [[-n  [[-n" [[-z  [[-z"
	      unset: false false true  false true  true  |false false false false true  true
	      null : false false true  false true  true  |false false false false true  true
	      space: false true  true  true  true  false |true  true  true  true  false false
	      zero : true  true  true  true  false false |true  true  true  true  false false
	      digit: true  true  true  true  false false |true  true  true  true  false false
	      char : true  true  true  true  false false |true  true  true  true  false false
	      hyphn: true  true  true  true  false false |true  true  true  true  false false
	      two  : -err- true  -err- true  -err- false |true  true  true  true  false false
	      part : -err- true  -err- true  -err- false |true  true  true  true  false false
	      Tstr : true  true  -err- true  -err- false |true  true  true  true  false false
	      Fsym : false true  -err- true  -err- false |true  true  true  true  false false
	      T=   : true  true  -err- true  -err- false |true  true  true  true  false false
	      F=   : false true  -err- true  -err- false |true  true  true  true  false false
	      T!=  : true  true  -err- true  -err- false |true  true  true  true  false false
	      F!=  : false true  -err- true  -err- false |true  true  true  true  false false
	      Teq  : true  true  -err- true  -err- false |true  true  true  true  false false
	      Feq  : false true  -err- true  -err- false |true  true  true  true  false false
	      Tne  : true  true  -err- true  -err- false |true  true  true  true  false false
	      Fne  : false true  -err- true  -err- false |true  true  true  true  false false

[[ "" ]]
[ "" ]
