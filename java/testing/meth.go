// package name: met
package main

import (
	"C"
	"fmt"
)


//export Hello
func Hello() {
	fmt.Println("Hello from go!");
}

func main() {} 
