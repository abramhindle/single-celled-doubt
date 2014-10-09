package main

import (
	"fmt"
	"time"
	"github.com/hypebeast/go-osc/osc"
	"github.com/edmontongo/gobot"
	"github.com/edmontongo/gobot/platforms/sphero"
	"encoding/json"
	"net/http"
	"html"
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

type TypeWrap struct {
	TypeName string
	Data interface{}
}

type ColourChange struct {
	R,G,B uint8
}


func sendCollision(client *osc.OscClient, c sphero.Collision) {
	msg := collisionMessage(c) 
	//fmt.Printf("Sending Collision %v\n", msg)
	strJson,_ := json.Marshal(TypeWrap{TypeName:"Collision", Data:c})
	//fmt.Printf("Sending Collision %v\n", string(strJson))
	SpamChannels(string(strJson))
	//SpamChannels(fmt.Sprintf("Sending Collision %v\n", msg))
	client.Send(  msg )
}

func sendLocator(client *osc.OscClient, l sphero.Locator) {
	msg := locatorMessage(l)
	//fmt.Printf("Sending Locator %v\n", msg)
	strJson,_ := json.Marshal(TypeWrap{TypeName:"Locator", Data:l})
	//fmt.Printf("Sending Locator %v\n", string(strJson))
	SpamChannels(string(strJson))
	client.Send( msg )
}

type OscCB struct {
	osc *osc.OscClient
}

func MakeOSCCB(osc * osc.OscClient) OscCB {
	return OscCB{osc}
}

func emotionMessage(emotion string) *osc.OscMessage {
	msg := osc.NewOscMessage("/emotion")
	msg.Append(string(emotion))
	return msg
}


func (cb OscCB) Cb(emoter * Emoter) {
	message := emotionMessage(emoter.Current)
	cb.osc.Send(message)
	strJson,_ := json.Marshal(TypeWrap{TypeName:"Emotion", Data:emoter.Current})
	fmt.Printf("Sending Emotion %v\n", string(strJson))
	SpamChannels(string(strJson))

}

type BotCmd struct {
	Speed int
	Angle int
}

func (b *BotCmd) Roll(d *sphero.SpheroDriver) {
	d.Roll(uint8(b.Speed), uint16((b.Angle + 360) % 360 ))
}

func main() {
	ip := "127.0.0.1"
	port := 57120
	client := osc.NewOscClient(ip, port)

	emoter := MakeEmoter()
	emoter.SetAll(MakeOSCCB(client))


	gbot := gobot.NewGobot()

	adaptor := sphero.NewSpheroAdaptor("Sphero", "/dev/rfcomm0")
	spheroDriver := sphero.NewSpheroDriver(adaptor, "sphero")

	colourChange := func(r, g, b uint8) {
		strJson,_ := json.Marshal(TypeWrap{TypeName:"Colour", Data:(ColourChange{r,g,b})})
		fmt.Printf("Sending Colour Change %v\n", string(strJson))
		SpamChannels(string(strJson))
		spheroDriver.SetRGB(r, g, b)		
	}

		
	botChan := make(chan BotCmd,100)


	defaultSpeed := 127

	turnLeft := SimpleHandler{
		"/bot/turn/left",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "left!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{0,-90}			
		},
	}
	turnRight := SimpleHandler{
		"/bot/turn/right",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "right!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{0,90}	
		},
	}
	forward := SimpleHandler{
		"/bot/move/forward",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "forward!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{defaultSpeed,0}				
		},
	}
	moveLeft := SimpleHandler{
		"/bot/move/left",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "left!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{defaultSpeed,-90}				
		},
	}
	moveRight := SimpleHandler{
		"/bot/move/right",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "right!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{defaultSpeed,90}				
		},
	}
	moveBack := SimpleHandler{
		"/bot/move/back",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "back!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{defaultSpeed,270}				
		},
	}



	square := SimpleHandler{
		"/bot/move/square",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "square!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{defaultSpeed,90}				
			botChan <- BotCmd{defaultSpeed,90}				
			botChan <- BotCmd{defaultSpeed,180}				
			botChan <- BotCmd{defaultSpeed,180}				
			botChan <- BotCmd{defaultSpeed,270}				
			botChan <- BotCmd{defaultSpeed,270}				
			botChan <- BotCmd{defaultSpeed,0}				
			botChan <- BotCmd{defaultSpeed,0}				

			/*
			botChan <- BotCmd{0,90}				
			botChan <- BotCmd{defaultSpeed,0}				
			botChan <- BotCmd{0,90}				
			botChan <- BotCmd{defaultSpeed,0}				
			botChan <- BotCmd{0,90}				
			botChan <- BotCmd{defaultSpeed,0}				
			botChan <- BotCmd{0,90}				
			botChan <- BotCmd{defaultSpeed,0}
                        */
		},
	}
	pause := SimpleHandler{
		"/bot/move/pause",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprintf(w, "pause!", html.EscapeString(r.URL.Path))
			botChan <- BotCmd{0,0}				
			botChan <- BotCmd{0,0}				
			botChan <- BotCmd{0,0}				
			botChan <- BotCmd{0,0}				
			botChan <- BotCmd{0,0}				
		},
	}




	handlers := []SimpleHandler {
		turnLeft,
		turnRight,
		forward,
		moveBack,
		moveLeft,
		moveRight,
		square,
		pause,
	}


	go Web(emoter, handlers)

	collisions := 0
	locations := 0
	work := func() {
		//spheroDriver.ConfigureCollisionDetectionRaw(40, 60, 40, 60, 100)
		spheroDriver.ConfigureCollisionDetectionRaw(0x30, 0x30, 0x30, 0x30, 20)
		//spheroDriver.ConfigureCollisionDetectionRaw(100, 10, 100, 10, 200)

		gobot.On(spheroDriver.Event("collision"), func(data interface{}) {
			fmt.Printf("Collision Detected!%+v\n", data)
			sendCollision(client,data.(sphero.Collision))
			collisions = collisions + 1
		})

		gobot.On(spheroDriver.Event("locator"), func(data interface{}) {
			fmt.Printf("Locator Detected!%+v\n", data)
			sendLocator(client,data.(sphero.Locator))
			locations = locations + 1
		})


		incd := 0
		gobot.Every(250 * time.Millisecond, func() {
			select {
			case cmd := <- botChan:
				fmt.Printf("\n\nGot a command %v\n\n", cmd)
				cmd.Roll(spheroDriver)
			default:	
				incd = incd + 1
				if (incd % 4 == 0) {
					fmt.Printf("\n\nMoving randomly\n\n")
					spheroDriver.Roll(uint8(gobot.Rand(128)), uint16(gobot.Rand(360)))
				}
			}
		})
		gobot.Every(time.Second, func() {
			if (collisions < 1 && locations < 1) {
				fmt.Printf("Trying to enable Collision Detection!\n")
				spheroDriver.ConfigureCollisionDetectionRaw(0x30, 0x30, 0x30, 0x30, 20)
				fmt.Printf("Trying to enable LOcator!\n")
				
				spheroDriver.ConfigureLocatorStreaming(2)
			}

		})

		gobot.Every(1*time.Second, func() {
			//spheroDriver.ConfigureLocatorStreaming(2)
			
			r := uint8(255)
			g := uint8(gobot.Rand(255))
			b := uint8(gobot.Rand(255))
			colourChange(r,g,b)

			//spheroDriver.SetRGB(r, g, b)
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
