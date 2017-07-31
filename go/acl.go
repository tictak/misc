package main

import (
	"fmt"
	"github.com/hsluoyz/casbin/api"
)

func main() {
	e := &api.Enforcer{}
	e.InitWithConfig("casbin.conf")
	fmt.Println(e.Enforce("bob", "/alice/fdsf", "POST"))
}
