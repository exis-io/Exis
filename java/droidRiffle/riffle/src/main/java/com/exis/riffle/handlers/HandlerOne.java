package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerOne<A> extends AnyHandler {
    default Class thisClass() { return HandlerOne.class; }
    void run(A a);
}
