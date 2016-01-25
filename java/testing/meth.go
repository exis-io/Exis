// math.go

package main

//export Multiply
func Multiply(x int64, y int64) int64 {
	return x * y
}

// main function is required, don't know why!
func main() {} // a dummy function
