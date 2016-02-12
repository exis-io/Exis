package com.exis.riffle.cumin;

import com.exis.riffle.Riffle;

/**
 * Created by damouse on 2/11/2016.
 */
public class Cumin {

    // The final state of Cuminicated methods. These are ready to fire as needed
    public interface Wrapped {
        Object invoke(Object... args);
    }

    public static Wrapped cuminicate(Handler.Zero fn) {
        return (q) -> { fn.run(); return null; };
    }

    public static <A> Wrapped cuminicate(Class<A> a, Handler.One<A> fn) {
        return (q) -> { fn.run(convert(a, q[0])); return null; };
    }

//    static <A, B> Wrapped cuminicate(Class<A> a, Class<B> b, Handler.Two<A, B> fn) {
//        return (q) -> { fn.run(convert(a, q[0])); return null; };
//    }
//
//    static <A, B, C> Wrapped cuminicate(Class<A> a, Class<A> b, Class<C> c, Handler.Three<A, B, C> fn) {
//        return (q) -> { fn.run(convert(a, q[0])); return null; };
//    }

    /**
     * Converts arbitrary object b to be of type A. Constructs the type if needed.
     */
    static <A> A convert(Class<A> a, Object b) {
        if (a.isInstance(b))
            return a.cast(b);

        if (a == Integer.class) {
            if (b instanceof Double) {
                return (A) Integer.valueOf(((Double) b).intValue());
            }
        }

        Riffle.error("PRIMITIVE CONVERSTION FALLTHROUGH. Want: " + a.toString() + ", received: " + b.getClass() + ", value: " + b.toString());
        return null;
    }
}
