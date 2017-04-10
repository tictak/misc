package main

import (
	"encoding/json"
	"fmt"
	"time"
)

func main() {
	b, e := json.Marshal(time.Minute)
	fmt.Println(time.Minute)
	fmt.Println(string(b), e)
	a()
}

type JsonTime time.Time

func (t JsonTime) MarshalJson() ([]byte, error) {
	return nil, nil
}

type JsonTime2 struct {
	time.Time
}

func (t JsonTime2) MarshalJson() ([]byte, error) {
	return nil, nil
}

func a() {
	type jsonint int
	type j struct {
		Ji jsonint `json:"jj"`
	}
	b, e := json.Marshal(j{10})
	fmt.Println(string(b), e)
	var jjj j
	e = json.Unmarshal([]byte(`{"jj":20}`), &jjj)
	fmt.Println(jjj, e)
}
