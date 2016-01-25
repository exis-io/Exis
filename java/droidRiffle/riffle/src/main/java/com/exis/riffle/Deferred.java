package com.exis.riffle;

/**
 * Created by damouse on 1/24/2016.
 *
 * Used to implement callbacks for almost all riffle operations.
 */
public class Deferred {
    int cb;
    int eb;

    Function _callback = null;
    Function _errback = null;


    public Deferred() {
        cb = Utils.newID();
        eb = Utils.newID();
    }
    public Deferred(App app) {
        this();

        app.deferreds.put(cb, this);
        app.deferreds.put(eb, this);
    }

    public Deferred then(Function callback) {
        _callback = callback;
        return this;
    }

    public Deferred error(Function errback) {
        _errback = errback;
        return this;
    }

    void callback() {
        if (_callback != null) {
            _callback.run();
        }
    }

    void errback() {
        if (_errback != null) {
            _errback.run();
        }
    }
}
