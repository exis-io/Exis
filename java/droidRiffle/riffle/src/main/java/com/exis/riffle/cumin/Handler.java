package com.exis.riffle.cumin;

/**
 * Created by damouse on 2/11/2016.
 *
 * All the different flavors of handler method, named based on the number of parameters they accept.
 *
 *
 */
public interface Handler {
    interface Zero { void run(); }
    interface One<A> { void run(A a); }
    interface Two<A, B> { void run(A a, B b); }
    interface Three<A, B, C> { void run(A a, B b, C c); }

    interface ZeroOne<R> { R run(); }
    interface OneOne<A, R> { R run(A a); }
    interface TwoOne<A, B, R> { R run(A a, B b); }
    interface ThreeOne<A, B, C, R> { R run(A a, B b, C c); }
}
