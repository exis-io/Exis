
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
    
    CGO_ENABLED=1 GOARCH=arm GOARM=7 go build -buildmode=c-shared -o libmath.so math.go

    CGO_ENABLED=0 GOARCH=arm GOOS=linux go build -buildmode=c-shared -o libmath.so math.go

    GOOS=android GOARCH=arm GOARM=7 go build -buildmode=c-shared -o libmath.so math.go


Compile and run: 
    javac -classpath jnr-ffi.jar Hello.java
    java -classpath jnr-ffi.jar:. Hello


/usr/local/java/jdk1.8.0_66/bin/javac -classpath jnr-ffi.jar Hello.java
/usr/local/java/jdk1.8.0_66/bin/java -classpath jnr-ffi.jar:. Hello

sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk1.8.0_66/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/jdk1.8.0_66/bin/javac" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/jdk1.8.0_66/bin/javaws" 1

*/
/* Attempt 1- Close, but jnr is unable to link

go build -buildmode=c-shared -o libmeth.so meth.go
javac -classpath jnr-ffi.jar Hello.java
java -classpath jnr-ffi.jar:. Hello

*/

// import jnr.ffi.LibraryLoader;
 
// interface MathLib {
//     long Multiply(long x, long y);
// }

// public class Hello {

//     private static final MathLib MATH_LIB;

//     static {
//         MATH_LIB = LibraryLoader.create(MathLib.class).load("meth");
//     }

//     public static void main(String[] args) {
//         System.out.println(MATH_LIB.Multiply(12345, 67890));
//         // output: 838102050
//     }
// }

/* Attempt 2-- sorta

*/

// import jnr.ffi.LibraryLoader;

// public class Hello {
//     public static native long multiply(long x, long y);

//     // public static interface MathLib {
//     //     long Multiply(long x, long y);
//     // }

//     // public static void main(String[] args) {
//     //     // MathLib libc = LibraryLoader.create(MathLib.class).load("math");
        
//     //     // System.out.println(libc.Multiply(12345, 67890));
        
//     //     // output: 838102050
//     //     //libc.puts("Hello, World");
//     // }
// }


/* Attempt 3 -- works, but boy is the jni interface

javac Hello.java
javah -cp . Hello
go build -buildmode=c-shared -o libmath.so math.go
java -cp . Hello


*/
// package io.dogan.whiteboard.jni;

// public class Hello {
//     public static native long multiply(long x, long y);

//     public static void main(String[] args) {
//         System.load("/home/damouse/code/merged/riffle/java/testing/libmath.so");
//         System.out.println(multiply(12345, 67890));
//     }
// }