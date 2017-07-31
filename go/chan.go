package main

import (
	"fmt"
	"time"
)

func main() {
	nilChan()
}

func nilChan() {
	c := make(chan bool, 1)
	c = nil
	for {
		select {
		case x, ok := <-c:
			fmt.Println(x, ok)
			break
		}
	}

	ch := make(chan bool, 1)
	ch2 := make(chan bool, 1)
	close(ch)
	close(ch2)
	for {
		select {
		case x, ok := <-ch:
			fmt.Println("ch1", x, ok)
			if !ok {
				ch = nil
			}
		case x, ok := <-ch2:
			fmt.Println("ch2", x, ok)
			if !ok {
				ch2 = nil
			}
		}

		if ch == nil && ch2 == nil {
			break
		}
	}
}

func readOnClosedChan() {
	b := make(chan bool)
	go func() {
		time.Sleep(time.Second * 1)
		close(b)
	}()
	for {
		select {
		case <-b:
			fmt.Println("HHHHHH")
		}
	}
	fmt.Println("done")
}
