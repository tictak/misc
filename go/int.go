package main

import (
	"fmt"
	"math"
)

func main() {
	var a uint32 = math.MaxUint32
	var b uint32 = 1000000
	fmt.Println(b - a)
	fmt.Println(a)
	d := uint32(math.MaxUint32 + 1)
	fmt.Println(d)
}
