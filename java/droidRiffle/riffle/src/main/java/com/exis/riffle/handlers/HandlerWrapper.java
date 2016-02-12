package com.exis.riffle.handlers;

import com.exis.riffle.Riffle;
import com.exis.riffle.handlers.AnyHandler;
import com.exis.riffle.handlers.Handler;
import com.exis.riffle.handlers.HandlerOne;
import com.exis.riffle.handlers.HandlerOneOne;

import net.jodah.typetools.TypeResolver;

public class HandlerWrapper {
    AnyHandler handler;
    Class[] types;

    public HandlerWrapper (AnyHandler handler) {
        // Since default and static methods get butchered by retrolambda, we have to resort
        // to more mundane ways of getting the real class of the handler

        Class target = null;

        if (handler instanceof Handler)
            target = Handler.class;
        else if (handler instanceof HandlerOne)
            target = HandlerOne.class;
        else if (handler instanceof HandlerTwo)
            target = HandlerTwo.class;
        else if (handler instanceof HandlerThree)
            target = HandlerThree.class;
        else if (handler instanceof HandlerOneOne)
            target = HandlerOneOne.class;
        else if (handler instanceof HandlerTwoOne)
            target = HandlerTwoOne.class;
        else if (handler instanceof HandlerThreeOne)
            target = HandlerThreeOne.class;
        else {
            Riffle.error("UNABLE TO DETERMINE HANDLER CLASS. Please pass a subclass of AnyHandler.");
        }

        if (target != null) {
            Riffle.debug("Target class: " + target.toString() + " getClass: " + handler.getClass().toString());
            types = TypeResolver.resolveRawArguments(target, handler.getClass());
            this.handler = handler;
        }
    }

    public Object invoke(Object[] args) {
        // Polymorphic solution is cleaner and more efficient here, but it also spreads the logic
        // across many, many files. May pursue that in the future

        if (handler instanceof Handler) {
            Handler fn = (Handler) handler;
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