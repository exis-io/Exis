package com.exis.riffle;

import com.exis.riffle.handlers.AnyHandler;

import go.mantle.Mantle;
//import me.tatarka.retrolambda.sample.lib.AnyHandler;

/**
 * Created by damouse on 1/23/16.
 *
 * See here for distribution: http://inthecheesefactory.com/blog/how-to-upload-library-to-jcenter-maven-central-as-dependency/en
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
            this.onJoin();
            return ""; // temp
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


    public Deferred subscribe(String endpoint, AnyHandler handler) {
        Deferred d = new Deferred(app);
        int fn = Utils.newID();

        app.handlers.put(fn, new HandlerTuple(handler, false));
        mantleDomain.Subscribe(endpoint,d.cb, d.eb, fn, "");
        return d;
    }

    public void register(String endpoint) {
//        mantleDomain.Register(endpoint);
    }

    public Deferred publish(String endpoint, Object... arguments) {
        Deferred d = new Deferred();
        mantleDomain.Publish(endpoint, d.cb, d.eb, Utils.marshall(arguments));
        return d;
    }

    public void call(String endpoint) {
//        mantleDomain.Call(endpoint);
    }

    public void unsubscribe(String endpoint) {
//        mantleDomain.Unsubscribe(endpoint);
    }

    public void unregister(String endpoint) {
//        mantleDomain.Unregister(endpoint);
    }

    public void Leave() {
        mantleDomain.Leave();
    }
}
