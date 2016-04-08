package com.example;

import java.lang.reflect.Field;

class Base {
    int b;
    public boolean a;
}

class Dog extends Base {
    String c;
    private double d;
}

/**
 * TODOLIST
 *      Pass cumin args down to the core
 *      Automatically serialize model objects and send them across
 *      Check errors as they come in, especially as it pertains to Cumin
 */
public class Testing {
    static void log(String s) {
        System.out.println(s);
    }

    public static void main(String[] args) {
        log("Hello, world!");

        for (Field f : Base.class.getDeclaredFields())  {
            log("Field: " + f.toString());
        }

        for (Field f : Dog.class.getDeclaredFields())  {
            log("Field: " + f.toString());
        }
    }
}
