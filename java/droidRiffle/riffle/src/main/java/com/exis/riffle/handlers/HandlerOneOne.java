package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerOneOne<A, R> extends AnyHandler {
    default Class thisClass() { return HandlerOneOne.class; }
    R run(A a);
}
