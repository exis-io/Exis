//math.go

package main

// #cgo CFLAGS: -I/usr/local/java/jdk1.8.0_66/include
// #cgo CFLAGS: -I/usr/local/java/jdk1.8.0_66/include/linux
// #include <jni.h>
import "C"

//export Java_Hello_multiply
func Java_Hello_multiply(env *C.JNIEnv, clazz C.jclass, x C.jlong, y C.jlong) C.jlong {
	return x * y
}

// main function is required, don't know why!
func main() {} // a dummy function
