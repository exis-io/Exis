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
public class AppDomain extends Domain {
    Thread thread;

    Map<BigInteger, HandlerTuple> handlers;
    Map<BigInteger, Deferred> deferreds;

    private Deferred controlOperation;

    protected AppDomain() {
        super();
        app = this;
    }

    public AppDomain(String name) {
        super(name);
        app = this;
        handlers = new ArrayMap();
        deferreds = new ArrayMap();

        mantleDomain = Mantle.NewDomain(name);
    }

    /* Connection Management */

    /**
     * Attempts to connect
     */
    public void join() {
        Riffle.debug("Starting main join method?");
        Deferred d = new Deferred(app);
        controlOperation = d;

        d.then(() -> {
            Riffle.debug("Triggering onJoin method");
            app.listen(mantleDomain);
            this.onJoin();
        });

        mantleDomain.Join(d.cb.toString(), d.eb.toString());
    }

    /**
     * Login with an account. If using Auth 1, pass username and password.
     * For Auth0 if you are logging in for the first time just pass a username-- if its not your first time
     * make sure to call join first!
     * @param credentials
     */
    public Deferred login(String... credentials) {
        if (credentials.length < 1 || credentials.length > 2) {
            Riffle.warn("You must pass at least a username and optionally a password");
            return null;
        }

        String username = credentials[0];
        String password = "";

        if(credentials.length == 2) {
            password = credentials[1];
        }

        Deferred d = new Deferred(this);
        controlOperation = d;
        mantleDomain.MentleLoginDomain(d.cb.toString(), d.eb.toString(), username, password);
        app.listen(mantleDomain);
        return d;
    }

    public Deferred registerDomain(String username, String password, String email, String name)  {
        Deferred d = new Deferred(this);
        controlOperation = d;
        mantleDomain.MentleRegisterDomain(d.cb.toString(), d.eb.toString(), username, password, email, name);
        app.listen(mantleDomain);
        return d;
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
                        Riffle.debug("AppDomain listen loop terminating");
                        break;
                    }

                    if (invocation[1] != null) {
                        ArrayList a = (ArrayList) invocation[1];
                        args = a.toArray();
                    }

                    if (controlOperation != null) {
                        if (id.compareTo(controlOperation.cb) == 0) {
                            controlOperation.callback(args);
                        } else if (id.compareTo(controlOperation.eb) == 0) {
                            controlOperation.errback(args);
                        } else {
                            Riffle.error("A control operation was requested, but not found!");
                        }

                        Riffle.debug("AppDomain listen loop terminating");
                        controlOperation = null;
                        break;
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

