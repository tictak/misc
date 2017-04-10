package main

import (
	"fmt"
	"time"
)

func main() {
	b := make(chan bool)
	go func() {
		time.Sleep(time.Second * 3)
		close(b)
	}()
	for {
		select {
		case <-b:
			fmt.Println("HHHHHH")
			goto done
		}
	}
done:
	fmt.Println("done")
}
