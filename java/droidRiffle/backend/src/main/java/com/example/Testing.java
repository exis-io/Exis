package com.example;

import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.GenericArrayType;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.TypeVariable;
import java.util.AbstractSequentialList;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


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


interface Two<A, B> extends AnyFunction {
    void run(A a, B b);
}

interface OneOne<A, R> extends AnyFunction {
    R run(A a);
}

class HandlerCarrier<A> {
    Class<A> internal = null;

    HandlerCarrier(One<A> fn) {
//        Testing.log("Class of carrier generic: " + Class<A>);
//        HandlerCarrier.<Integer>receiver(1);

//        internal = (Class<A>)
//                ((ParameterizedType)getClass()
//                        .getGenericSuperclass())
//                        .getActualTypeArguments()[0];
    }

    static <T> void receiver(T t) {

    }

    public String toString() {
        StringBuilder sb = new StringBuilder();

        Class<?> thisClass = null;
        try {
            thisClass = Class.forName(this.getClass().getName());

            Field[] aClassFields = thisClass.getDeclaredFields();
            sb.append(this.getClass().getSimpleName() + " [ ");
            for(Field f : aClassFields){
                String fName = f.getName();
                sb.append("(" + f.getType() + ") " + fName + " = " + f.get(this) + ", ");
            }
            sb.append("]");
        } catch (Exception e) {
            e.printStackTrace();
        }

        return sb.toString();
    }
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
        Cuminicated a = register(() -> {
            log("No args handler firing");
        });

        Cuminicated b = register(Integer.class, Testing::functionPointerOne);

        Cuminicated c = register(Boolean.class, (happy) -> {
            log("OneOne closure firing " + happy);
        });

        a.invoke();
        b.invoke(1);
        c.invoke(true);
    }

    static Cuminicated register(Zero fn) {
        return (args) -> {
            fn.run();
            return null;
        };
    }

    static <A> Cuminicated register(Class<A> a, One<A> fn) {
        return (args) -> {
            fn.run(a.cast(args[0]));
            return null;
        };
    }
}

interface Cuminicated {
    Object invoke(Object... args);
}





/* Experiments. Some of them almost worked!
    static <T> MyClass<T> goat() {
        MyClass<T> myClass2 = new MyClass<T>() { };
        return myClass2;
    }

         So close, but easure takes over when the generics are recaptured :(
        MyClass<Double> myClass2 = new MyClass<Double>() { };         // only sorcerers do this
        MyClass c = Testing.<Boolean>goat();

        TypeTokenTree z = new TypeTokenTree(c.getClass());
        log("Come now: " + z.getRoot().children);


*/


class MyClass<T> {
     final Class<?> typeT;

    public MyClass() {
        this.typeT = new TypeTokenTree(this.getClass()).getElement(0);
        Testing.log("Type: :" + this.typeT);
    }
}


class TypeTokenTree {
    final TypeNode root;

    public TypeTokenTree() {
        this.root = retrieve(getClass());
    }

    public TypeTokenTree(final Class<?> klass) {
        this.root = retrieve(klass);
    }

    public Class<?> getElement(final int pos) {
        if (root==null) {
            return null;
        }
        final TypeNode typeNode = root.get(pos);
        if (typeNode==null) {
            return null;
        }
        return typeNode.getElement();
    }

    public TypeNode getRoot() {
        return root;
    }

     TypeNode retrieve(final Class<?> klass) {
        final Type superclass = klass.getGenericSuperclass();
//        QL.require(!(superclass instanceof Class) , ReflectConstants.SHOULD_BE_ANONYMOUS_OR_EXTENDED); // QA:[RG]::verified
        final TypeNode node = new TypeNode(klass);
        for (final Type t : ((ParameterizedType) superclass).getActualTypeArguments() ) {
            node.add(retrieve(t));
        }
        return node;
    }

     TypeNode retrieve(final Type type) {
        final TypeNode node;
        if (type instanceof Class<?>) {
            node = new TypeNode((Class<?>)type);
        } else if (type instanceof ParameterizedType) {
            final Type rawType = ((ParameterizedType) type).getRawType();
            node = retrieve(rawType);
            for (final Type arg : ((ParameterizedType) type).getActualTypeArguments()) {
                node.add(retrieve(arg));
                //
                //TODO: code review
                //
                // More test cases need to be done, specially related to Monte Carlo needs on generic parameters
                //
                //        } else if (type instanceof TypeVariable) {
                //            GenericDeclaration declaration = ((TypeVariable) type).getGenericDeclaration();
                //            node = new TypeNode(declaration);
                //            for (Type arg : ((TypeVariable) type).getBounds()) {
                //                node.add(retrieve(arg));
                //            }
                //
            }
        } else {
//            throw new IllegalArgumentException(ReflectConstants.ILLEGAL_TYPE_PARAMETER);
            node = null;
        }

        return node;
    }
}

class TypeNode {

     final Class<?> element;
     final AbstractSequentialList<TypeNode> children;

    public TypeNode(final Class<?> klass) {
        this.element = klass;
        this.children = new LinkedList<TypeNode>();
    }

    public Class<?> getElement() {
        return element;
    }

    public TypeNode get(final int index) {
        return children.get(index);
    }

    public Iterable<TypeNode> children() {
        return children;
    }

    TypeNode add(final Class<?> klass) {
        final TypeNode node = new TypeNode(klass);
        children.add(node);
        return node;
    }

    TypeNode add(final TypeNode node) {
        children.add(node);
        return node;
    }
}