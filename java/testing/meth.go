// math.go

package main

func main() {} // a dummy function

//export Multiply
func Multiply(x int64, y int64) int64 {
	return x * y
}
