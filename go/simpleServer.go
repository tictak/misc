package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(time.Second * 10)
		fmt.Fprintf(w, `{"retcode":0}`)
		return
	})
	fmt.Println(http.ListenAndServe(":8081", nil))
}
