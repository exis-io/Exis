package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface HandlerNone extends AnyHandler {
    default Class thisClass() { return HandlerNone.class; }
    void run();
}
