package com.exis.riffle;

import com.exis.riffle.handlers.AnyHandler;
import com.exis.riffle.handlers.HandlerWrapper;

/**
 * Created by damouse on 1/24/2016.
 *
 * Used to implement callbacks for almost all riffle operations.
 */
public class Deferred {
    int cb;
    int eb;

    HandlerWrapper _callback = null;
    HandlerWrapper _errback = null;


    public Deferred() {
        cb = Utils.newID();
        eb = Utils.newID();
    }
    public Deferred(App app) {
        this();

        app.deferreds.put(cb, this);
        app.deferreds.put(eb, this);
    }

    public Deferred then(AnyHandler callback) {
        _callback = new HandlerWrapper(callback);
        return this;
    }

    public Deferred error(AnyHandler errback) {
        _errback = new HandlerWrapper(errback);
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
}
