package com.example;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.AbstractSequentialList;
import java.util.LinkedList;

interface Handler {
    interface Zero { void run(); }
    interface One<A> { void run(A a); }
    interface Two<A, B> { void run(A a, B b); }

    interface OneOne<A, R> { R run(A a); }
}

interface Cuminicated {
    Object invoke(Object... args);
}

public class Testing {
    static void log(String s) {
        System.out.println(s);
    }

    public static void main(String[] args) {
        testClosures();
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

    // Since we'll need duplicates for all the handlers, it may be easier to consolidate
    static Cuminicated register(Handler.Zero fn) {
        return (args) -> { fn.run(); return null; };
    }

    static <A> Cuminicated register(Class<A> a, Handler.One<A> fn) {
        return cuminicate(a, fn);
    }

    static <A> Cuminicated cuminicate(Class<A> a, Handler.One<A> fn) {
        return (args) -> { fn.run(convert(a, args[0])); return null; };
    }

    // Converts arbitrary object b to be of type A. Constructs the type if needed
    static <A> A convert(Class<A> a, Object b) {
        return a.cast(b);
    }
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