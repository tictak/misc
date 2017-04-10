package main

import (
	"fmt"
	"hash/adler32"
	"hash/crc32"
	"strconv"
	"strings"
	"time"
)

func main() {
	var b = 'c'
	b = b + 'a'
	b = b + 'a'
	fmt.Println(b)
}

func a() {
	for i := 0; i < 100; i++ {
		fmt.Println(crc32.ChecksumIEEE([]byte(strconv.Itoa(i))))
	}
	fmt.Println("___________________________________________")
	for i := 0; i < 100; i++ {
		fmt.Println(adler32.Checksum([]byte(strconv.Itoa(i))))
	}
	fmt.Println("___________________________________________")

	num := 10000000
	t := time.Now()
	for i := 0; i < num; i++ {
		adler32.Checksum([]byte(strings.Repeat("a", 200)))
	}
	fmt.Println(time.Now().Sub(t))
	t = time.Now()
	fmt.Println("___________________________________________")
	for i := 0; i < num; i++ {
		crc32.ChecksumIEEE([]byte(strings.Repeat("a", 200)))
	}
	fmt.Println(time.Now().Sub(t))

}
