package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerThreeOne<A, B, C, R> extends AnyHandler {
    R run(A a, B b, C c);
}
