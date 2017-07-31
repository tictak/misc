package main

import (
	"fmt"
	"regexp"
)

func main() {
	b()
}

func b() {
	str := `update natserver set addr='30.0.0.206',enable=0,unavailable=0 where name='cszx-tproxy5';`
	var updateReg = regexp.MustCompile(`update (?P<a>\w+) set`)
	fmt.Println(updateReg.MatchString(str))
	fmt.Println(updateReg.FindStringSubmatch((str)))
}

func a(s string) string {
	reg := regexp.MustCompile("(.)(\\d)")
	return reg.ReplaceAllString(s, "${2}${1}")
}
