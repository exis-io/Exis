package com.exis.riffle;

import android.util.ArrayMap;

import com.exis.riffle.cumin.Cumin;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/23/16.
 *
 * Manages a single session, including the connection itself and all domains attached to it.
 */
class App {
    Mantle.Domain mantleDomain;
    Thread thread;

    Map<Integer, HandlerTuple> handlers;
    Map<Integer, Deferred> deferreds;

    App() {
        handlers = new ArrayMap();
        deferreds = new ArrayMap();
    }

    /**
     * Spins on a connection and listens for callbacks from the core.
     */
    void listen(Mantle.Domain domain) {
        mantleDomain = domain;

        thread = new Thread() {
            public void run() {

                while (true) {
                    Object[] invocation = Utils.unmarshall(mantleDomain.Receive());
                    Object[] args = {};

                    Double temp = (Double) invocation[0];
                    int id = temp.intValue();

                    if (id == 0) {
                        Riffle.debug("App listen loop terminating");
                        break;
                    }

                    if (invocation[1] != null) {
                        ArrayList a = (ArrayList) invocation[1];
                        args = a.toArray();
                    }

                    //Riffle.debug("Crust received invocation: " + id + " args: " + args.toString());

                    if (deferreds.containsKey(id)) {
                        Deferred d = deferreds.remove(id);

                        // TODO: try/catch

                        // Remove the deferred and trigger it appropriately
                        if (id == d.cb) {
                            deferreds.remove(d.eb);

                            d.callback(args);
                        } else {
                            deferreds.remove(d.cb);
                            d.errback(args);
                        }
                    }

                    if (handlers.containsKey(id)) {
                        HandlerTuple t = handlers.get(id);

                        // TODO: try/catch

                        if (t.isRegistration) {
                            // CAREFUL-- this isn't going to work if the mantle is still dealing in longs!
                            Double yieldId = (Double) args[0];
                            Object result = t.fn.invoke(Arrays.copyOfRange(args, 1, args.length));

                            Object[] packed = {result};
                            mantleDomain.Yield(yieldId.longValue(), Utils.marshall(packed));
                        } else {
                            t.fn.invoke(args);
                        }
                    }
                }
            }
        };

        thread.start();
    }
}

// Simple class that stores a little metadata with the handler
class HandlerTuple {
    Cumin.Wrapped fn = null;
    boolean isRegistration = false;

    HandlerTuple(Cumin.Wrapped function, boolean isRegistration) {
        fn = function;
        this.isRegistration = isRegistration;
    }
}