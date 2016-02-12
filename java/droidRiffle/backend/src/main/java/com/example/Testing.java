package com.example;

import net.jodah.typetools.TypeResolver;

import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.List;


// Attempt
interface AnyFunction {
    default Object invoke(Object... args) { return null; }
}

interface Zero extends AnyFunction {
    void run();
}

interface One<A> extends AnyFunction {
    void run(A a);
}

interface OneOne<A, R> extends AnyFunction {
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

public class Testing {
    static void log(String s) {
        System.out.println(s);
    }

    public static void main(String[] args) {
        testClosures();
    }

    static void functionPointer() {
        log("No args Function pointer firing");
    }

    static void functionPointerOne(Integer a) {
        log("One arg Function pointer firing" + a);
    }

    static void testClosures() {
//        HandlerWrapper a = register((Zero) () -> {
//            log("No args handler firing");
//        });

        HandlerWrapper b = register((One<Integer>) Testing::functionPointerOne);

        HandlerWrapper c = register((OneOne<Boolean, Float>) (happy) -> {
            log("OneOne closure firing " + happy);
            return 10.f;
        });

//        a.invoke();
//        b.invoke(1);
//        c.invoke(true);
    }

    static HandlerWrapper  register(AnyFunction fn) {
//        log("Dynamic: " + fn.thisClass());

        Class target = null;

        if (fn instanceof Zero)
            target = Zero.class;

        if (fn instanceof One)
            target = One.class;

        if (fn instanceof OneOne)
            target = OneOne.class;

        log("Target class: " + target.toString() + " getClass: " + fn.getClass().getName());

        Type t = ((ParameterizedType)fn.getClass().getGenericSuperclass()).getActualTypeArguments()[0];

        log("Interface: " + fn.getClass().getGenericInterfaces());
        log("Superclass: " + fn.getClass().getGenericSuperclass());

        log("Type ARgs: " + t.toString());
        // Class[] typeArgs = TypeResolver.resolveRawArguments(target, fn.getClass());

        // TODO: drop into collections and model objects and apply recursively. Arrays dont reflect,
        // lists have their internal types erased, and model objects will need to do this themselves :(
//        for (Class c: typeArgs) {
//            log("Type: " + c.toString());
//        }

//        HandlerWrapper  wrapped = new HandlerWrapper (fn, typeArgs);
//        return wrapped;
        return null;

//        log("TYPES: " + typeArgs.toString());
//        assert typeArgs[0] == String.class;
//        assert typeArgs[1] == Integer.class;
    }
}
