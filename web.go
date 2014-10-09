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

type SimpleHandler struct {
	Path string
	Handler http.HandlerFunc
}

func (s *SimpleHandler) Register() {
	http.HandleFunc(s.Path, s.Handler)
}


func Web(emoter Emoter, handlers []SimpleHandler) {

	// go eventGenerator()

	HelloWorldHandler := HelloWorldHandler{}

	http.Handle("/hello", HelloWorldHandler)	
	http.HandleFunc("/world", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "World HELLO! %q", html.EscapeString(r.URL.Path))
	})	
	http.HandleFunc("/emotion/happy", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Happy!", html.EscapeString(r.URL.Path))
		emoter.Happy()
	})	
	http.HandleFunc("/emotion/angry", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Angry!", html.EscapeString(r.URL.Path))
		emoter.Angry()
	})	
	http.HandleFunc("/emotion/sad", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Angry!", html.EscapeString(r.URL.Path))
		emoter.Sad()
	})	
	http.HandleFunc("/emotion/bored", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Angry!", html.EscapeString(r.URL.Path))
		emoter.Bored()
	})	

	for _, handler := range handlers {
		handler.Register()
	}

	http.Handle("/event", websocket.Handler(EventServer))
	http.Handle("/", http.FileServer(http.Dir("static")))
	log.Fatal(http.ListenAndServe(":6660", nil))
	
}
