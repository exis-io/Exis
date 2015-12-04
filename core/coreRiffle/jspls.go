package goriffle

/*
Extracts the blob, but how to get the data?
    http://stackoverflow.com/questions/17990353/reading-bytes-from-a-javascript-blob-received-by-websocket

Using a filereader:
    https://git.emersion.fr/saucisse-royale/miko/raw/e488d152181215cb3b5cbcd6ed8ac6bfc3de8d9b/server/browser/mapper/terrain/export.go
*/

import (
	"fmt"

	"github.com/gopherjs/gopherjs/js"
	"github.com/gopherjs/websocket"
)

var sock *websocket.WebSocket

func onMessage(a *js.Object) {
	blob := a.Get("data")
	// fmt.Println("Received blob: ", blob.Call("size"))

	fileReader := js.Global.Get("FileReader").New()
	fileReader.Call("addEventListener", "load", func() {
		ret := []byte(fileReader.Get("result").String())

		fmt.Println("Contents of blob: ", ret)

		s := new(messagePackSerializer)
		if msg, err := s.deserialize(ret); err == nil {
			fmt.Println("Done: ", msg)
		} else {
			fmt.Println("Error deserializing: ", err)
		}
	})

	fileReader.Call("readAsBinaryString", blob)

	// fmt.Println("Blob size: ", blob.Call("size"))
}

func onOpen(a *js.Object) {
	fmt.Println("Opened: ", a)

	s := new(messagePackSerializer)
	h := &hello{Realm: "xs.damouse", Details: map[string]interface{}{}}

	if b, err := s.serialize(h); err == nil {
		sock.Send(b)
	} else {
		fmt.Println("Unable to serialize message: ", err)
	}
}

func onClose(a *js.Object) {
	fmt.Println("Closed: ", a)
}

func onError(a *js.Object) {
	fmt.Println("Error: ", a)
}

func GoJs(url string, domain string) {
	ws, err := websocket.New(url) // Does not block.
	// ws.BinaryType = "arraybuffer"
	sock = ws

	if err != nil {
		fmt.Println("Unable to create socket!")
	}

	// onOpen := func(ev *js.Object) {
	// 	err := ws.Send([]byte("Hello!")) // Send as a binary frame
	// 	err := ws.Send("Hello!")         // Send a text frame
	// }

	ws.AddEventListener("open", false, onOpen)
	ws.AddEventListener("message", false, onMessage)
	ws.AddEventListener("close", false, onClose)
	ws.AddEventListener("error", false, onError)

}
