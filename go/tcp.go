package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	laddr := &net.TCPAddr{IP: net.ParseIP(os.Args[1])}
	d := net.Dialer{LocalAddr: laddr}
	conn, err := d.Dial("tcp", os.Args[2]+":80")
	fmt.Println(conn, err)
}
