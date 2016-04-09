package com.exis.riffle;

import android.util.ArrayMap;

import com.exis.riffle.cumin.Cumin;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.BitSet;
import java.util.Map;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/23/16.
 *
 * Manages a single session, including the connection itself and all domains attached to it.
 */
class App extends Domain {
    Thread thread;

    Map<BigInteger, HandlerTuple> handlers;
    Map<BigInteger, Deferred> deferreds;

    protected App() {
        super();
    }

    public App(String name) {
        super(name);
        handlers = new ArrayMap();
        deferreds = new ArrayMap();

        mantleDomain = Mantle.NewDomain(name);
    }

    /* Connection Management */
    public void join() {
        Deferred d = new Deferred(app);

        d.then(() -> {
            Riffle.debug("Triggering onJoin method");
            this.onJoin();
        });

        mantleDomain.Join(d.cb.toString(), d.eb.toString());
        app.listen(mantleDomain);
    }

    public void login() {

    }

    public void registerDomain(String username, String password, String email, String name) {
//        String result = mantleDomain.RegisterDomain(username, password, email, name);

//        if (result == "Success") {
//
//        }
    }

    public void reconnect() {
        Riffle.warn("THIS METHOD IS NOT IMPLEMENTED");
    }

    public void disconnect() {
        Riffle.warn("THIS METHOD IS NOT IMPLEMENTED");
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

                    BigInteger id = Utils.convertCoreInt64(invocation[0]);

                    if (id.compareTo(BigInteger.valueOf(0)) == 0) {
                        Riffle.debug("App listen loop terminating");
                        break;
                    }

                    if (invocation[1] != null) {
                        ArrayList a = (ArrayList) invocation[1];
                        args = a.toArray();
                    }

                    //Riffle.debug("Got invocation: " + id.toString() + " " + args.toString());

                    if (deferreds.containsKey(id)) {
                        Deferred d = deferreds.remove(id);

                        // TODO: try/catch

                        // Remove the deferred and trigger it appropriately
                        if (id.compareTo(d.cb) == 0) {
                            deferreds.remove(d.eb);

                            d.callback(args);
                        } else {
                            deferreds.remove(d.cb);
                            d.errback(args);
                        }
                    }

                    else if (handlers.containsKey(id)) {
                        HandlerTuple t = handlers.get(id);

                        // TODO: try/catch their exceptions

                        if (t.isRegistration) {
                            BigInteger yieldId = Utils.convertCoreInt64(args[0]);
                            Object result = t.fn.invoke(Arrays.copyOfRange(args, 1, args.length));

                            Object[] packed = {result};
                            mantleDomain.Yield(yieldId.toString(), Utils.marshall(packed));
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

