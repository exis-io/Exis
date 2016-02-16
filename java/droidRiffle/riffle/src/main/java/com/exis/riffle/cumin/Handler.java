package com.exis.riffle.cumin;

/**
 * Created by damouse on 2/11/2016.
 *
 * All the different flavors of handler method, named based on the number of parameters they accept.
 *
 *
 */
public interface Handler {
    // Start Generic Shotgun

interface ZeroZero { void run(); }

interface OneZero<A> { void run(A a); }

interface TwoZero<A, B> { void run(A a, B b); }

interface ThreeZero<A, B, C> { void run(A a, B b, C c); }

interface FourZero<A, B, C, D> { void run(A a, B b, C c, D d); }

interface FiveZero<A, B, C, D, E> { void run(A a, B b, C c, D d, E e); }

interface SixZero<A, B, C, D, E, F> { void run(A a, B b, C c, D d, E e, F f); }

interface ZeroOne<R> { R run(); }

interface OneOne<A, R> { R run(A a); }

interface TwoOne<A, B, R> { R run(A a, B b); }

interface ThreeOne<A, B, C, R> { R run(A a, B b, C c); }

interface FourOne<A, B, C, D, R> { R run(A a, B b, C c, D d); }

interface FiveOne<A, B, C, D, E, R> { R run(A a, B b, C c, D d, E e); }

interface SixOne<A, B, C, D, E, F, R> { R run(A a, B b, C c, D d, E e, F f); }
// End Generic Shotgun
}
