package main

import (
	"fmt"
)

func main() {

	fmt.Println(dedup([]string{"1", "2", "1"}))
}

func dedup(slice []string) (uniq []string) {
	m := make(map[string]bool, len(slice))
	uniq = make([]string, 0, len(slice))
	for _, v := range slice {
		if m[v] {
			continue
		}
		m[v] = true
		uniq = append(uniq, v)
	}
	return
}
