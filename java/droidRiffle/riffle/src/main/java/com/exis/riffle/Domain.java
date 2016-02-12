package com.exis.riffle;

import android.util.Log;

import com.exis.riffle.cumin.Cumin;
import com.exis.riffle.cumin.Handler;

import go.mantle.Mantle;
//import me.tatarka.retrolambda.sample.lib.AnyHandler;

/**
 * Created by damouse on 1/23/16.
 *
 * See here for distribution: http://inthecheesefactory.com/blog/how-to-upload-library-to-jcenter-maven-central-as-dependency/en
 *
 * TODO: emit different kinds of deferreds based on handlers
 */
public class Domain {
    private Mantle.Domain mantleDomain;
    private App app;

    /* Constructurs */
    public Domain(String name) {
        mantleDomain = Mantle.NewDomain(name);
        app = new App();
    }

    public Domain(String name, Domain superdomain) {
        mantleDomain = superdomain.mantleDomain.Subdomain(name);
        app = superdomain.app;
    }


    /* Connection Management */
    public void join() {
        Deferred d = new Deferred(app);

        d.then(() -> {
            Riffle.debug("Triggering onJoin method");
            this.onJoin();
        });

        mantleDomain.Join(d.cb, d.eb);
        app.listen(mantleDomain);
    }

    public void onJoin() {
        Riffle.debug("Default domain join");
    }

    public void onLeave() {
        Riffle.debug("Default domain leave");
    }


    Deferred _subscribe(String endpoint, Cumin.Wrapped handler) {
        Deferred d = new Deferred(app);
        int fn = Utils.newID();

        app.handlers.put(fn, new HandlerTuple(handler, false));
        mantleDomain.Subscribe(endpoint, d.cb, d.eb, fn, "");
        return d;
    }

    Deferred _register(String endpoint, Cumin.Wrapped handler) {
        Deferred d = new Deferred(app);
        int fn = Utils.newID();

        app.handlers.put(fn, new HandlerTuple(handler, true));
        mantleDomain.Register(endpoint, d.cb, d.eb, fn, "");
        return d;
    }

    public Deferred publish(String endpoint, Object... arguments) {
        Deferred d = new Deferred();
        mantleDomain.Publish(endpoint, d.cb, d.eb, Utils.marshall(arguments));
        return d;
    }

    public Deferred call(String endpoint, Object... arguments) {
        Deferred d = new Deferred();
        mantleDomain.Call(endpoint, d.cb, d.eb, Utils.marshall(arguments));
        return d;
    }

    public Deferred unsubscribe(String endpoint) {
        // TODO: remove handler

        Deferred d = new Deferred();
        mantleDomain.Unsubscribe(endpoint, d.cb, d.eb);
        return d;
    }

    public Deferred unregister(String endpoint) {
        // TODO: remove handler

        Deferred d = new Deferred();
        mantleDomain.Unregister(endpoint, d.cb, d.eb);
        return d;
    }

    public void leave() {
        mantleDomain.Leave();
    }


    //
    // Wrapper methods
    //
    public <A> Deferred subscribe(String endpoint, Class<A> a, Handler.One<A> handler) {
        return _subscribe(endpoint, Cumin.cuminicate(a, handler));
    }

    public <A> Deferred register(String endpoint, Class<A> a, Handler.One<A> handler) {
        return _register(endpoint, Cumin.cuminicate(a, handler));
    }
}

