package main

import (
	"fmt"
)

const (
	a = iota
	_
	d
)
const c = iota

func main() {
	fmt.Println(a, d, c)
}
