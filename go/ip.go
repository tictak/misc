package main

import (
	"encoding/binary"

	"fmt"
	"net"
	"strconv"
	"strings"
)

func main() {
	cidr := "118.190.0.0/15"
	fmt.Println(CIDR(cidr))
	cidr = "118.190.0.0/16"
	fmt.Println(CIDR(cidr))
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
