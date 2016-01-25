package com.exis.riffle;

import android.util.ArrayMap;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Handler;

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
        handlers = new ArrayMap<Integer, HandlerTuple>();
        deferreds = new ArrayMap<Integer, Deferred>();
    }

    /**
     * Spins on a connection and listens for callbacks from the core.
     */
    void listen(Mantle.Domain domain) {
        mantleDomain = domain;

        thread = new Thread() {
            public void run() {
                Riffle.debug("App thread starting");
                
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

                    //Riffle.debug("Crust invocation: " + id + " " + args);

                    if (deferreds.containsKey(id)) {
                        Deferred d = deferreds.remove(id);

                        // TODO: try/catch
                        // Remove the deferred and trigger it appropriately
                        if (id == d.cb) {
                            deferreds.remove(d.eb);
                            d.callback();
                        } else {
                            deferreds.remove(d.cb);
                            d.errback();
                        }
                    }

                    if (handlers.containsKey(id)) {
                        HandlerTuple t = handlers.get(id);

                        // TODO: try/catch
                        // TODO: returns
                        t.fn.run();
                    }
                }
            }
        };

        thread.start();
    }
}

class HandlerTuple {
    Function fn = null;
    boolean isRegistration = false;

    HandlerTuple(Function function, boolean isRegistration) {
        fn = function;
        this.isRegistration = isRegistration;
    }

}