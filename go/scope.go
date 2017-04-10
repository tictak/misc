package main

import (
	"fmt"
)

func main() {
	fmt.Println(errScope())
}

func errScope() (err error) {
	a, err := 10, fmt.Errorf("out")
	{
		b, err := 10, fmt.Errorf("in")
		fmt.Println(b, err)
	}
	fmt.Println(a, err)
	return
}
