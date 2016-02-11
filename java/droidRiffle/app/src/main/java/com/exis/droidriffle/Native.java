package com.exis.droidriffle;

//import com.exis.riffle.Domain;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/24/16.
 */
//public class Native {
//
//    public static void main(String[] args){
//        System.out.println("Hello, World!");
////        String javaLibPath = System.getProperty("java.library.path");
////        System.out.println("Path: " + javaLibPath);
//
////        Domain d = new Domain("asdf");
//    }
//}

import jnr.ffi.LibraryLoader;



interface Handler {
    void run();
}
interface HandlerOne<T> {
    void run(T a);
}

public class Native {
    static void log(String s) {
        System.out.println(s);
    }

    // Declare the interface for the shared library
    public static interface MathLib {
        void Hello();
    }

    public static void main(String[] args) {
        testLibrary();
//        testClosures();
    }

    static void testLibrary() {
        LibraryLoader<MathLib> loader = LibraryLoader.create(MathLib.class);

        // NEED THIS FOR NOW-- either the location of the library is not correct wrt
        // android studio or jnr-ffi just doesn't understand where Android studio is holding the libs
        loader.search("/home/damouse/code/merged/riffle/java/testing");

        MathLib libc = loader.load("meth");

        // Testing to make sure the go code runs
        libc.Hello();
    }

    static void functionPointer() {
        log("No args AnyHandler pointer firing");
    }

    static void testClosures() {
        register((Handler)() -> {
            log("No args handler firing");
        });

        register((Handler) Native::functionPointer);
    }

    static void register(Object fn) {
        log("Class: " + fn.getClass());

        //boolean isObject = fn instanceof
        log("Is object: " + (fn instanceof Object));

        Handler realFunction = (Handler) fn;

        realFunction.run();
    }

//    static void registerAny(Lamb)
}
