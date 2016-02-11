package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface Handler extends AnyHandler {
    default Class thisClass() { return Handler.class; }
    void run();
}
