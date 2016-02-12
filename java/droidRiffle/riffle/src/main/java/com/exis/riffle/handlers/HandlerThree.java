package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerThree<A, B, C> extends AnyHandler {
    void run(A a, B b, C c);
}
