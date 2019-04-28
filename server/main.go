package main

import (
	"bufio"
	"fmt"
	"os"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func main() {
	opt := mqtt.NewClientOptions()
	opt.AddBroker("tcp://graduation-project.mqtt.iot.bj.baidubce.com:1883")
	opt.SetUsername("graduation-project/xiaomi")
	opt.SetPassword("uQcpeTOlJOAFK3gE")

	c := mqtt.NewClient(opt)
	if token := c.Connect(); token.Wait() && token.Error() != nil {
		panic(token.Error())
	}

	inputReader := bufio.NewReader(os.Stdin)
	fmt.Printf("推送系统启动\n")
	for true {
		fmt.Printf("推送消息: ")
		input, _ := inputReader.ReadString('\n')
		c.Publish("message", 1, false, input)
	}

}
