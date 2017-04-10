package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

var counter = 0

var concnt = flag.Int("concnt", 100, "concurrent get count")
var domainfile = flag.String("file", "result.result", "domain list file")
var timeout = flag.Int("timeout", 1, "http get timeout")

func main() {
	flag.Parse()
	f, err := os.Open(*domainfile)
	if err != nil {
		log.Panic(err)
	}

	r := bufio.NewReader(f)
	var readErr error
	var domain string
	var domainlist []string
	for readErr != io.EOF {
		domain, readErr = r.ReadString('\n')
		domainlist = append(domainlist, strings.TrimSuffix(domain, "\n"))
	}

	domainChan := make(chan string, 100)

	go runDomain(domainlist, domainChan)

	for i := 0; i < *concnt; i++ {
		go oneGuy(domainChan)
	}
	done := make(chan bool)
	done <- true
}

func runDomain(domainlist []string, domainChan chan<- string) {
	tmpcount := 0
	for {
		start := time.Now()
		for _, domain := range domainlist {
			domainChan <- domain
		}
		finish := counter - tmpcount
		tmpcount = counter
		fmt.Printf("LOOP:%f %d\n", time.Now().Sub(start).Seconds(), finish)
	}
}

func oneGuy(domainChan <-chan string) {
	sndCount := time.Duration(*timeout)
	client := &http.Client{
		Timeout: time.Second * sndCount,
	}
	for domain := range domainChan {
		curl(domain, client)
	}
}

func curl(domain string, client *http.Client) {
	defer func() {
		counter++
		//	fmt.Println(counter)
	}()
	resp, err := client.Get("http://" + domain)
	if err != nil {
		log.Println(err)
	} else {
		resp.Body.Close()
	}
}
