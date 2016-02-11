package com.example;

//import com.exis.droidriffle.Model;

import net.jodah.typetools.TypeResolver;

import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.util.List;

// Attempt
interface AnyFunction {
    default Class thisClass() { return AnyFunction.class; }
    default Object invoke(Object... args) { return null; }
}

interface Zero extends AnyFunction {
    default Class thisClass() { return Zero.class; }
    void run();
}

interface One<A> extends AnyFunction {
    default Class thisClass() { return One.class; }
    void run(A a);
}

interface OneOne<A, R> extends AnyFunction {
    default Class thisClass() { return OneOne.class; }
    R run(A a);
}

// Wraps handlers
class HandlerWrapper {
    AnyFunction handler;
    Class[] types;

    HandlerWrapper (AnyFunction handler, Class[] types) {
        this.handler = handler;
        this.types = types;
    }

    Object invoke(Object... args) {
        // Polymorphic solution is cleaner and more efficient here, but it also spreads the logic
        // across many, many files. May pursue that in the future

        if (handler instanceof Zero) {
            Zero fn = (Zero) handler;
            fn.run();
            return null;
        }
        else if (handler instanceof One) {
            One fn = (One) handler;
            fn.run(types[0].cast(args[0]));
            return null;
        }
        else if (handler instanceof OneOne) {
            OneOne fn = (OneOne) handler;
            return fn.run(types[0].cast(args[0]));
        }
        else {
            System.out.println("WARN-- Serious fallthrough. Cannot determine type of handler");
            return null;
        }
    }
}

//class Curried

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
        log("One arg Function pointer firing" + a);
    }

    static void testClosures() {
        HandlerWrapper a = register((Zero) () -> {
            log("No args handler firing");
        });

        HandlerWrapper b = register((One<Integer>) Backend::functionPointerOne);

        HandlerWrapper c = register((OneOne<Boolean, Float>) (happy) -> {
            log("OneOne closure firing " + happy);
            return 10.f;
        });

        a.invoke();
        b.invoke(1);
        c.invoke(true);
    }

    static HandlerWrapper  register(AnyFunction fn) {
//        log("Dynamic: " + fn.thisClass());

        Class[] typeArgs = TypeResolver.resolveRawArguments(fn.thisClass(), fn.getClass());

        // TODO: drop into collections and model objects and apply recursively. Arrays dont reflect,
        // lists have their internal types erased, and model objects will need to do this themselves :(
//        for (Class c: typeArgs) {
//            log("Type: " + c.toString());
//        }

        HandlerWrapper  wrapped = new HandlerWrapper (fn, typeArgs);
        return wrapped;

//        log("TYPES: " + typeArgs.toString());
//        assert typeArgs[0] == String.class;
//        assert typeArgs[1] == Integer.class;
    }
}
