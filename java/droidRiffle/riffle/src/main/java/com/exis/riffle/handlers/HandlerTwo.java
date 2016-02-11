package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerTwo<A, B> extends AnyHandler {
    default Class thisClass() { return HandlerTwo.class; }
    void run(A a, B b);
}
