package com.example;

//import com.exis.droidriffle.Model;

import net.jodah.typetools.TypeResolver;

import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.util.List;

public class Backend {
    static void log(String s) {
        System.out.println(s);
    }

    // Declare the interface for the shared library
    public static interface MathLib {
        void Hello();
    }

    public static void main(String[] args) {
        testLibrary();
    }
}
