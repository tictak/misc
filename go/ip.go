package main

import (
	"encoding/binary"
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintf(os.Stderr, "Usage %s 1.1.1.0/24 12", os.Args[0])
		os.Exit(1)
	}
	start, end, net, mask, err := CIDR(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s: %s", os.Args[1], err)
		os.Exit(1)
	}

	fmt.Printf("('%s','%s','%s',%d,%s)\n", start, end, net, mask, os.Args[2])
}

func CIDR(s string) (ipstart, ipend, ipnet string, mask uint, err error) {
	list := strings.Split(s, "/")
	if len(list) != 2 {
		err = fmt.Errorf("format error: %s", s)
		return
	}

	ip := net.ParseIP(list[0])
	maskU64, err := strconv.ParseUint(list[1], 10, 32)
	if err != nil || maskU64 > 32 {
		err = fmt.Errorf("mask error: %s", list[1])
		return
	}
	mask = uint(maskU64)
	if ip2int(ip)&(1<<(32-mask)-1) != 0 {
		err = fmt.Errorf("mask error2: %s", list[1])
		return
	}
	intStart := ip2int(ip) &^ (1<<(32-mask) - 1)
	ipstart = int2ip(intStart).String()
	ipend = int2ip(intStart | (1<<(32-mask) - 1)).String()
	ipnet = ipstart
	return
}

func ip2int(ip net.IP) uint32 {
	return binary.BigEndian.Uint32(ip[12:16])
}

func int2ip(u uint32) net.IP {
	ip := make(net.IP, 4)
	binary.BigEndian.PutUint32(ip, u)
	return ip
}
