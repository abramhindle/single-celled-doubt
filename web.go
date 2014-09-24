package main

import (
	"net/http"
	"log"	
	"fmt"
	"html"
	"code.google.com/p/go.net/websocket"
	"time"
)

var evch []chan string

func SpamChannels(event string) {
	for _, ochan := range evch {
		ochan <- event
	}
}

func eventGenerator() {
	for {
		SpamChannels(time.Now().String())
		time.Sleep(1 * time.Second)		
	}
}

func EventServer(ws *websocket.Conn) {
	input := make(chan string)
	evch = append(evch,input)
	fmt.Printf("EventSender")
	for {

		event := <- input
		ws.Write([]byte(event))
	}
}


type HelloWorldHandler struct {}

func (f HelloWorldHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World %q", html.EscapeString(r.URL.Path))
}

func Web() {

	// go eventGenerator()

	HelloWorldHandler := HelloWorldHandler{}

	http.Handle("/hello", HelloWorldHandler)	
	http.HandleFunc("/world", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "World HELLO! %q", html.EscapeString(r.URL.Path))
	})	
	http.Handle("/event", websocket.Handler(EventServer))
	http.Handle("/", http.FileServer(http.Dir("static")))
	log.Fatal(http.ListenAndServe(":8080", nil))
	
}
