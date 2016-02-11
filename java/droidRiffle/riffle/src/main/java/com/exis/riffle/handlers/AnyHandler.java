package com.exis.riffle.handlers;

/**
 * Created by damouse on 1/24/2016.
 */

public interface AnyHandler {
    default Class thisClass() { return AnyHandler.class; }
    default Object invoke(Object... args) { return null; }
}