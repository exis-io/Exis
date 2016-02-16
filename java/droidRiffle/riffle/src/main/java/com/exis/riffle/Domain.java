package com.exis.riffle;

import android.util.Log;

import com.exis.riffle.cumin.Cumin;
import com.exis.riffle.cumin.Handler;

import java.math.BigInteger;

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

//        d.then(() -> {
//            Riffle.debug("Triggering onJoin method");
//            this.onJoin();
//        });

        mantleDomain.Join(d.cb.toString(), d.eb.toString());
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
        BigInteger fn = Utils.newID();

        app.handlers.put(fn, new HandlerTuple(handler, false));
        mantleDomain.Subscribe(endpoint, d.cb.toString(), d.eb.toString(), fn.toString(), "");
        return d;
    }

    Deferred _register(String endpoint, Cumin.Wrapped handler) {
        Deferred d = new Deferred(app);
        BigInteger fn = Utils.newID();

        app.handlers.put(fn, new HandlerTuple(handler, true));
        mantleDomain.Register(endpoint, d.cb.toString(), d.eb.toString(), fn.toString(), "");
        return d;
    }

    public Deferred publish(String endpoint, Object... arguments) {
        Deferred d = new Deferred();
        mantleDomain.Publish(endpoint, d.cb.toString(), d.eb.toString(), Utils.marshall(arguments));
        return d;
    }

    public CallDeferred call(String endpoint, Object... arguments) {
        CallDeferred d = new CallDeferred();
        mantleDomain.Call(endpoint, d.cb.toString(), d.eb.toString(), Utils.marshall(arguments));
        return d;
    }

    public Deferred unsubscribe(String endpoint) {
        // TODO: remove handler

        Deferred d = new Deferred();
        mantleDomain.Unsubscribe(endpoint, d.cb.toString(), d.eb.toString());
        return d;
    }

    public Deferred unregister(String endpoint) {
        // TODO: remove handler

        Deferred d = new Deferred();
        mantleDomain.Unregister(endpoint, d.cb.toString(), d.eb.toString());
        return d;
    }

    public void leave() {
        mantleDomain.Leave();
    }


    //
    // Start Generic Shotgun

public  Deferred subscribe(String endpoint,  Handler.ZeroZero handler) {
    return _subscribe(endpoint, Cumin.cuminicate(handler));
}

public <A> Deferred subscribe(String endpoint, Class<A> a,  Handler.OneZero<A> handler) {
    return _subscribe(endpoint, Cumin.cuminicate(a, handler));
}

public <A, B> Deferred subscribe(String endpoint, Class<A> a, Class<B> b,  Handler.TwoZero<A, B> handler) {
    return _subscribe(endpoint, Cumin.cuminicate(a, b, handler));
}

public <A, B, C> Deferred subscribe(String endpoint, Class<A> a, Class<B> b, Class<C> c,  Handler.ThreeZero<A, B, C> handler) {
    return _subscribe(endpoint, Cumin.cuminicate(a, b, c, handler));
}

public <A, B, C, D> Deferred subscribe(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d,  Handler.FourZero<A, B, C, D> handler) {
    return _subscribe(endpoint, Cumin.cuminicate(a, b, c, d, handler));
}

public <A, B, C, D, E> Deferred subscribe(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e,  Handler.FiveZero<A, B, C, D, E> handler) {
    return _subscribe(endpoint, Cumin.cuminicate(a, b, c, d, e, handler));
}

public <A, B, C, D, E, F> Deferred subscribe(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<F> f,  Handler.SixZero<A, B, C, D, E, F> handler) {
    return _subscribe(endpoint, Cumin.cuminicate(a, b, c, d, e, f, handler));
}

public  Deferred register(String endpoint,  Handler.ZeroZero handler) {
    return _register(endpoint, Cumin.cuminicate(handler));
}

public <A> Deferred register(String endpoint, Class<A> a,  Handler.OneZero<A> handler) {
    return _register(endpoint, Cumin.cuminicate(a, handler));
}

public <A, B> Deferred register(String endpoint, Class<A> a, Class<B> b,  Handler.TwoZero<A, B> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, handler));
}

public <A, B, C> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c,  Handler.ThreeZero<A, B, C> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, handler));
}

public <A, B, C, D> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d,  Handler.FourZero<A, B, C, D> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, d, handler));
}

public <A, B, C, D, E> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e,  Handler.FiveZero<A, B, C, D, E> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, d, e, handler));
}

public <A, B, C, D, E, F> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<F> f,  Handler.SixZero<A, B, C, D, E, F> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, d, e, f, handler));
}

public <R> Deferred register(String endpoint, Class<R> r,  Handler.ZeroOne<R> handler) {
    return _register(endpoint, Cumin.cuminicate(r, handler));
}

public <A, R> Deferred register(String endpoint, Class<A> a, Class<R> r,  Handler.OneOne<A, R> handler) {
    return _register(endpoint, Cumin.cuminicate(a, r, handler));
}

public <A, B, R> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<R> r,  Handler.TwoOne<A, B, R> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, r, handler));
}

public <A, B, C, R> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<R> r,  Handler.ThreeOne<A, B, C, R> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, r, handler));
}

public <A, B, C, D, R> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<R> r,  Handler.FourOne<A, B, C, D, R> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, d, r, handler));
}

public <A, B, C, D, E, R> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<R> r,  Handler.FiveOne<A, B, C, D, E, R> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, d, e, r, handler));
}

public <A, B, C, D, E, F, R> Deferred register(String endpoint, Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<F> f, Class<R> r,  Handler.SixOne<A, B, C, D, E, F, R> handler) {
    return _register(endpoint, Cumin.cuminicate(a, b, c, d, e, f, r, handler));
}
    // End Generic Shotgun
}
