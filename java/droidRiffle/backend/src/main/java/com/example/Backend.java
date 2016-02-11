package com.example;

//import com.exis.droidriffle.Model;

import net.jodah.typetools.TypeResolver;

import java.lang.reflect.ParameterizedType;
import java.util.List;

// Attempt
interface AnyFunction {
    default Class thisClass() { return AnyFunction.class; }

    // Reflect the arguments for the handler
    default String cumin() { return "DEFAULT"; }

    //default String mapTypes() { return ""; }
}

interface Zero extends AnyFunction {
    default Class thisClass() { return Zero.class; }

    default String cumin() { return "[]"; }

    void run();
}

interface One<A> extends AnyFunction {
    default Class thisClass() { return One.class; }

//    default String cumin() { return A; }

    void run(A a);
}

interface OneOne<A, R> extends AnyFunction {
    default Class thisClass() { return OneOne.class; }

    default String cumin() { return "DEFAULT"; }

    R run(A a);
}

public class Backend {
    static void log(String s) {
        System.out.println(s);
    }

    // Declare the interface for the shared library
    public static interface MathLib {
        void Hello();
    }

    public static void main(String[] args) {
//        testLibrary();
        testClosures();
    }

    static void functionPointer() {
        log("No args Function pointer firing");
    }

    static void functionPointerOne(Integer a) {
        log("No args Function pointer firing");
    }

    static void testClosures() {
        // Attempting to pass the type literals in like python and js. Type earasure means
        // Deeply nested collections wont work
        //AnyFunction a = want(String.class, String[].class, Integer.class).cast(Backend::functionPointer);

        register((Zero) () -> {
            log("No args handler firing");
        });

        register((Zero) Backend::functionPointer);

        //Zero a = Backend::functionPointer;
        //a.cumin();

        register((One<Integer>) Backend::functionPointerOne);

        register((OneOne<Boolean, Float>) (a) -> {
            return 10.f;
        });

    }

    static void register(AnyFunction fn) {
        log("Class: " + fn.getClass());
        log("Dynamic: " + fn.thisClass());

        Class unwrappedClosure = fn.thisClass();

//        System.out.println(fn.getClass().getGenericSuperclass()); //output: GenericClass<Foo>
//        System.out.println(((ParameterizedType) fn.getClass().getGenericSuperclass()).getActualTypeArguments()[0]); //output: class Foo

//        Function<String, Integer> strToInt = s -> Integer.valueOf(s);
        Class<?>[] typeArgs = TypeResolver.resolveRawArguments(fn.thisClass(), fn.getClass());

        for (Class c: typeArgs) {
            log("Type: " + c.toString());
        }

//        log("TYPES: " + typeArgs.toString());
//        assert typeArgs[0] == String.class;
//        assert typeArgs[1] == Integer.class;
    }
}
