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

public class Native {
    static void log(String s) {
        System.out.println(s);
    }

    // Declare the interface for the shared library
    public static interface Mantle {
        void Hello();
    }

    public static void main(String[] args) {
        testLibrary();
    }

    static void testLibrary() {
        System.out.println("Working Directory = " + System.getProperty("user.dir"));
        System.out.println("Operating system: " + System.getProperty("os.name"));

        LibraryLoader<Mantle> loader = LibraryLoader.create(Mantle.class);

        // NEED THIS FOR NOW-- either the location of the library is not correct wrt
        // android studio or jnr-ffi just doesn't understand where Android studio is holding the libs
//        loader.search("/home/damouse/code/merged/riffle/java/testing");

        Mantle mantle = loader.load("meth");

        // Testing to make sure the go code runs
        mantle.Hello();
    }
}
