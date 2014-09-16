package main

import (
	"github.com/hypebeast/go-osc/osc"
)

func main() {
    ip := "localhost"
    port := 57120

    client := osc.NewOscClient(ip, port)
    msg := osc.NewOscMessage("/osc/address")
    msg.Append(int32(111))
    msg.Append(true)
    msg.Append("hello")
    msg.Append("Locator Test")
    msg.Append(int16(1))

    client.Send(msg)
}
