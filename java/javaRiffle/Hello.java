
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

Install this using Maven or some other tool
*/

import com.sun.jna.Library;
import com.sun.jna.Native;

public class Hello {
    public interface Mantle extends Library {
        public void HelloJava();
    }

    static public void main(String argv[]) {
        Mantle mantle = (Mantle) Native.loadLibrary("mantle", Mantle.class);
        System.out.println(mantle);
        mantle.HelloJava();
    }
}