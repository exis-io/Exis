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

/**
 * Getting builds from the command line:
 *      - Make sure the gradle wrapper exists: 'gradle wrapper' at root
 *      -
 */

public class Native {
    // Declare the interface for the shared library
    public static interface MathLib {
        void Hello();
    }

    public static void main(String[] args) {
        LibraryLoader<MathLib> loader = LibraryLoader.create(MathLib.class);

        // NEED THIS FOR NOW-- either the location of the library is not correct wrt
        // android studio or jnr-ffi just doesn't understand where Android studio is holding the libs
        loader.search("/home/damouse/code/merged/riffle/java/testing");

        MathLib libc = loader.load("meth");

        // Testing to make sure the go code runs
        libc.Hello();

        /*
        Yay! Next steps:
            - Check all type passing
            - Verify object passing
            - Create JAR or AAR from mantle and crust
            - Upload jar/aar
            - Make sure "backend" can be created and compiled from command line
        */

    }
}
