package main

import (
	"fmt"
	"time"
	"github.com/hypebeast/go-osc/osc"
	"github.com/edmontongo/gobot"
	"github.com/edmontongo/gobot/platforms/sphero"
)

func collisionMessage(c sphero.Collision) *osc.OscMessage {
	msg := osc.NewOscMessage("/collision")
	msg.Append(int32(c.X))
	msg.Append(int32(c.Y))
	msg.Append(int32(c.Z))
	msg.Append(int32(c.Axis))
	msg.Append(int32(c.XMagnitude))
	msg.Append(int32(c.YMagnitude))
	msg.Append(int32(c.Speed))
	return msg
}

func locatorMessage(l sphero.Locator) *osc.OscMessage {
	msg := osc.NewOscMessage("/locator")
	msg.Append(int32(l.Xpos))
	msg.Append(int32(l.Ypos))
	msg.Append(int32(l.Accel))
	msg.Append(int32(l.Xvel))
	msg.Append(int32(l.Yvel))
	return msg
}


func sendCollision(client *osc.OscClient, c sphero.Collision) {
	msg := collisionMessage(c) 
	fmt.Printf("Sending Collision %v\n", msg)
	client.Send(  msg )
}

func sendLocator(client *osc.OscClient, l sphero.Locator) {
	msg := locatorMessage(l)
	fmt.Printf("Sending Locator %v\n", msg)
	client.Send( msg )
}


func main() {
	ip := "127.0.0.1"
	port := 9999
	client := osc.NewOscClient(ip, port)
	


	gbot := gobot.NewGobot()

	adaptor := sphero.NewSpheroAdaptor("Sphero", "/dev/rfcomm0")
	spheroDriver := sphero.NewSpheroDriver(adaptor, "sphero")
	collisions := 0
	work := func() {
		//spheroDriver.ConfigureCollisionDetectionRaw(40, 60, 40, 60, 100)
		spheroDriver.ConfigureCollisionDetectionRaw(0x10, 0x01, 0x10, 0x01, 200)
		//spheroDriver.ConfigureCollisionDetectionRaw(100, 10, 100, 10, 200)

		gobot.On(spheroDriver.Event("collision"), func(data interface{}) {
			fmt.Printf("Collision Detected!%+v\n", data)
			sendCollision(client,data.(sphero.Collision))
			collisions = collisions + 1
		})

		gobot.On(spheroDriver.Event("locator"), func(data interface{}) {
			fmt.Printf("Locator Detected!%+v\n", data)
			sendLocator(client,data.(sphero.Locator))
		})


		gobot.Every(time.Second, func() {
			spheroDriver.Roll(uint8(gobot.Rand(128)), uint16(gobot.Rand(360)))
			fmt.Printf("Collisions: %v\n", collisions)

		})
		gobot.Every(time.Second, func() {
			if (collisions < 1) {
				fmt.Printf("Trying to enable Collision Detection!\n")
				spheroDriver.ConfigureCollisionDetectionRaw(0x20, 0x20, 0x20, 0x20, 200)
				fmt.Printf("Trying to enable LOcator!\n")

				spheroDriver.ConfigureLocatorStreaming(2)
			}
		})

		gobot.Every(1*time.Second, func() {
			//spheroDriver.ConfigureLocatorStreaming(2)
			r := uint8(255)
			g := uint8(gobot.Rand(255))
			b := uint8(gobot.Rand(255))
			spheroDriver.SetRGB(r, g, b)
		})

		//spheroDriver.ConfigureCollisionDetectionRaw(200, 0, 125, 0, 100)


	}

	robot := gobot.NewRobot("sphero",
		[]gobot.Connection{adaptor},
		[]gobot.Device{spheroDriver},
		work,
	)

	gbot.AddRobot(robot)

	gbot.Start()
}
