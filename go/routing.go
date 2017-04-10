package main

import (
	"fmt"
	"net"
	"runtime"
	"time"
)

type Wrap struct {
	c net.Conn
}

func main() {

	go func() {
		defer func() {
			fmt.Println("EEEEEEEEE")
		}()
		c, e := net.Dial("tcp", "127.0.0.1:80")
		fmt.Println(c, e)
		w := Wrap{c}
		fmt.Println(w)
		time.Sleep(time.Second * 5)
		runtime.GC()
	}()
	fmt.Println("FFFFF")
	done := make(chan bool)
	<-done
}
