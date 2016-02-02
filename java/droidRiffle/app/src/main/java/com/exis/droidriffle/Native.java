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
    public static native long multiply(long x, long y);

    public static interface MathLib {
        long Multiply(long x, long y);
    }

    public static void main(String[] args) {
        MathLib libc = LibraryLoader.create(MathLib.class).load("meth");

        System.out.println(libc.Multiply(12345, 67890));

        // output: 838102050
        //libc.puts("Hello, World");
    }
}
