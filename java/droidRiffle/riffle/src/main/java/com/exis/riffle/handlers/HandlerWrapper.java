package com.exis.riffle.handlers;

import com.exis.riffle.handlers.AnyHandler;
import com.exis.riffle.handlers.HandlerNone;
import com.exis.riffle.handlers.HandlerOne;
import com.exis.riffle.handlers.HandlerOneOne;

public class HandlerWrapper {
    AnyHandler handler;
    Class[] types;

    HandlerWrapper (AnyHandler handler, Class[] types) {
        this.handler = handler;
        this.types = types;
    }

    Object invoke(Object... args) {
        // Polymorphic solution is cleaner and more efficient here, but it also spreads the logic
        // across many, many files. May pursue that in the future

        if (handler instanceof HandlerNone) {
            HandlerNone fn = (HandlerNone) handler;
            fn.run();
            return null;
        }
        else if (handler instanceof HandlerOne) {
            HandlerOne fn = (HandlerOne) handler;
            fn.run(types[0].cast(args[0]));
            return null;
        }
        else if (handler instanceof HandlerOneOne) {
            HandlerOneOne fn = (HandlerOneOne) handler;
            return fn.run(types[0].cast(args[0]));
        }
        else {
            System.out.println("WARN-- Serious fallthrough. Cannot determine type of handler");
            return null;
        }
    }
}