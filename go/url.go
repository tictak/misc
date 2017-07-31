package main

import (
	"fmt"
	"net/url"
)

func main() {
	v, e := url.ParseRequestURI("http://www.baidu.com/index?a=1234&b=4555")
	fmt.Println(v, e)
	v1, e := url.ParseQuery("http://www.baidu.com/index?a=1234&b=4555")
	for k, kk := range v1 {
		fmt.Println(k, kk)
	}
}
