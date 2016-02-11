package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerTwoOne<A, B, R> extends AnyHandler {
    default Class thisClass() { return HandlerTwoOne.class; }
    R run(A a, B b);
}