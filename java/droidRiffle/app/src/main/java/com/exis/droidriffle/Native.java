package com.exis.droidriffle;

import com.exis.riffle.Domain;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/24/16.
 */
public class Native {

    public static void main(String[] args){
        System.out.println("Hello, World!");
//        String javaLibPath = System.getProperty("java.library.path");
//        System.out.println("Path: " + javaLibPath);

        Domain d = new Domain("asdf");
    }
}
