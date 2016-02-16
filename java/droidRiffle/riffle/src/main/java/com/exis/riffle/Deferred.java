package com.exis.riffle;

import com.exis.riffle.cumin.Cumin;
import com.exis.riffle.cumin.Handler;

import java.math.BigInteger;

/**
 * Created by damouse on 1/24/2016.
 *
 * Used to implement callbacks for almost all riffle operations.
 */
public class Deferred {
    BigInteger cb;
    BigInteger eb;

    Cumin.Wrapped _callback = null;
    Cumin.Wrapped _errback = null;


    public Deferred() {
        cb = Utils.newID();
        eb = Utils.newID();
    }

    public Deferred(App app) {
        this();

        app.deferreds.put(cb, this);
        app.deferreds.put(eb, this);
    }

    // We will need to override cuminicable methods here again, much like swift
    Deferred _then(Cumin.Wrapped fn) {
        _callback = fn;
        return this;
    }

    Deferred _error(Cumin.Wrapped fn) {
        _errback = fn;
        return this;
    }

    void callback(Object[] args) {
        if (_callback != null) {
            _callback.invoke(args);
        }
    }

    void errback(Object[] args) {
        if (_errback != null) {
            _errback.invoke(args);
        }
    }

    //
    // Generic Shotgun
    //

    // No args
    public Deferred then(Handler.ZeroZero handler) {
        return _then (Cumin.cuminicate(handler));
    }

    public Deferred error(Handler.ZeroZero handler) {
        return _error(Cumin.cuminicate(handler));
    }
}

