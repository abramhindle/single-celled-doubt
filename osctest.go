package main

import (
	"github.com/hypebeast/go-osc/osc"
)
func genMessage() *osc.OscMessage {
	msg := osc.NewOscMessage("/locator")
	msg.Append(int32(1))
	msg.Append(int32(2))
	msg.Append(int32(3))
	msg.Append(int32(4))
	msg.Append(int32(5))
	msg.Append("Locator Test")
	return msg
}

func main() {
	ip := "localhost"
	port := 6666
	client := osc.NewOscClient(ip, port)
	msg := genMessage()
	client.Send( msg )
	client.Send( msg )
	client.Send( msg )
	client.Send( msg )
	client.Send( msg )
	client.Send( msg )
	client.Send( msg )
	client.Send( msg )

}
