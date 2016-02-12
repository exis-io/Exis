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

class Handler {

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
//        MyClass<Integer> a = new MyClass<Integer>() {};
        MyClass<Double> myClass2 = new MyClass<Double>() { };         // only sorcerers do this



//        HandlerWrapper a = register((Zero) () -> {
//            log("No args handler firing");
//        });

//        new HandlerCarrier<Integer>(Testing::functionPointerOne);
//
//        HandlerWrapper b = register((One<Integer>) Testing::functionPointerOne);
//
//        Testing.<Integer>subscribe(Testing::functionPointerOne);
//        Testing.<Boolean, String>subscribe((a, c) -> {
//
//        });

//        HandlerWrapper c = register((OneOne<Boolean, Float>) (happy) -> {
//            log("OneOne closure firing " + happy);
//            return 10.f;
//        });

//        a.invoke();
//        b.invoke(1);
//        c.invoke(true);
    }

    static <T> HandlerWrapper subscribe(One<T> fn) {

        HandlerCarrier<T> please = new HandlerCarrier<T>(fn) {};
//        log(((Class<T>) ((ParameterizedType) please.getClass().getGenericSuperclass()).getActualTypeArguments()[0]).getSimpleName());
//        Class<T> whatami = new Class<T>();
//        log("" + please.internal.getClass());

//        ParameterizedType type = (ParameterizedType) please.getClass().getGenericSuperclass();
//        log("HELL: " + please.toString());

//        log("" + getTypeArguments(HandlerCarrier.class, please.getClass()));
//        log("Class: " + whatami);
        return null;
    }

    static <T, S> HandlerWrapper subscribe(Two<T, S> fn) {

        return null;
    }


    static HandlerWrapper  register(AnyFunction fn) {
        log("Dynamic: " + fn.getClass());

        Class target = null;

        if (fn instanceof Zero)
            target = Zero.class;

        if (fn instanceof One)
            target = One.class;

        if (fn instanceof OneOne)
            target = OneOne.class;

//        log("Target class: " + target.toString() + " getClass: " + fn.getClass().getName());

        Method[] m = fn.getClass().getMethods();
//
//        for (Class c: m[0].getParameterTypes()) {
//            System.out.println("Class: " + c.toString());
//        }
//
//        for (Type c: m[0].getGenericParameterTypes()) {
//            System.out.println("Generic: " + c.getTypeName());
//        }

//        log("Types: " + getParameterizedTypes(fn));

//        log("\tParams: " + m[0].getParameterTypes());
//        log("\tGenerics:: " + m[0].getGenericParameterTypes());


        return null;
//        Class[] typeArgs = Silver.resolveRawArguments(target, fn.getClass());
//
//        // TODO: drop into collections and model objects and apply recursively. Arrays dont reflect,
//        // lists have their internal types erased, and model objects will need to do this themselves :(
////        for (Class c: typeArgs) {
////            log("Type: " + c.toString());
////        }
//
//        HandlerWrapper  wrapped = new HandlerWrapper (fn, typeArgs);
//        return wrapped;

    }
}



class MyClass<T> {
    private final Class<?> typeT;

    public MyClass() {
        this.typeT = new TypeTokenTree(this.getClass()).getElement(0);
        Testing.log("Type: :" + this.typeT);
    }
}






class TypeToken {

    static public Type getType(final Class<?> klass) {
        return getType(klass, 0);
    }

    static public Type getType(final Class<?> klass, final int pos) {
        final Type superclass = klass.getGenericSuperclass();
//        QL.require(!(superclass instanceof Class) , ReflectConstants.SHOULD_BE_ANONYMOUS_OR_EXTENDED); // QA:[RG]::verified
        final Type[] types = ((ParameterizedType) superclass).getActualTypeArguments();
//        QL.require(pos < types.length , ReflectConstants.MISSING_GENERIC_PARAMETER_TYPE); // QA:[RG]::verified
        return types[pos];
    }

    static public Class<?> getClazz(final Class<?> klass) {
        return getClazz(klass, 0);
    }

    static public Class<?> getClazz(final Class<?> klass, final int pos) {
        final Type type = getType(klass, pos);
        final Class<?> clazz = (type instanceof Class<?>) ? (Class<?>) type : (Class<?>) ((ParameterizedType) type).getRawType();
//        QL.require(((clazz.getModifiers() & Modifier.ABSTRACT) == 0) , ReflectConstants.GENERIC_PARAMETER_MUST_BE_CONCRETE_CLASS); // QA:[RG]::verified
        return clazz;
    }

}





class TypeTokenTree {

    //
    // private fields
    //

    private final TypeNode root;


    //
    // public constructors
    //

    public TypeTokenTree() {
        this.root = retrieve(getClass());
    }

    public TypeTokenTree(final Class<?> klass) {
        this.root = retrieve(klass);
    }

    /**
     * Returns the Class of a generic parameter
     *
     * @param pos represents the position of parameter, first is zero
     * @return the Class of a generic parameter
     */
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

    //
    // public methods
    //

    public TypeNode getRoot() {
        return root;
    }


    //
    // private methods
    //

    private TypeNode retrieve(final Class<?> klass) {
        final Type superclass = klass.getGenericSuperclass();
//        QL.require(!(superclass instanceof Class) , ReflectConstants.SHOULD_BE_ANONYMOUS_OR_EXTENDED); // QA:[RG]::verified
        final TypeNode node = new TypeNode(klass);
        for (final Type t : ((ParameterizedType) superclass).getActualTypeArguments() ) {
            node.add(retrieve(t));
        }
        return node;
    }

    private TypeNode retrieve(final Type type) {
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

    //
    // private fields
    //

    private final Class<?> element;
    private final AbstractSequentialList<TypeNode> children;


    //
    // public constructors
    //

    public TypeNode(final Class<?> klass) {
        this.element = klass;
        this.children = new LinkedList<TypeNode>();
    }


    //
    // public methods
    //

    /**
     * @return the contents of this TypeNode
     */
    public Class<?> getElement() {
        return element;
    }

    public TypeNode get(final int index) {
        return children.get(index);
    }

    public Iterable<TypeNode> children() {
        return children;
    }


    //
    // package protected methods
    //

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