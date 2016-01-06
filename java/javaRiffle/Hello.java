
/*
Testing using a shared library with Java

Download JNA.jar:
    https://maven.java.net/content/repositories/releases/net/java/dev/jna/jna/4.2.1/jna-4.2.1.jar
    mv jna-4.2.1.jar jna.jar

Compile C: 
    gcc -o libctest.so -shared ctest.c

Compile Java: 
    javac -classpath jna.jar Hello.java

Run:
    java -classpath jna.jar:. Hello


Above doesn't work. This looks very promising: 
    https://blog.dogan.io/2015/08/15/java-jni-jnr-go/

Download jar, rename it to jnr-ffi.jar: 
    http://mvnrepository.com/artifact/com.github.jnr/jnr-ffi/2.0.7

Build shared: 
    go build -buildmode=c-shared -o libmath.so math.go

Compile and run: 
    javac -classpath jnr-ffi.jar Hello.java MathLib.java
    java -classpath jnr-ffi.jar:. Hello

*/

// import jnr.ffi.LibraryLoader;

// public class Hello {

//     private static final MathLib MATH_LIB;

//     static {
//         MATH_LIB = LibraryLoader.create(MathLib.class).load("math");
//     }

//     public static void main(String[] args) {
//         System.out.println(MATH_LIB.Multiply(12345, 67890));
//         // output: 838102050
//     }
// }

import jnr.ffi.LibraryLoader;

public class Hello {
    public static interface LibC {
        long Multiply(long x, long y);
    }

    public static void main(String[] args) {
        LibC libc = LibraryLoader.create(LibC.class).load("math");
        System.out.println(libc.Multiply(12345, 67890));
        // output: 838102050

        //libc.puts("Hello, World");
    }
}