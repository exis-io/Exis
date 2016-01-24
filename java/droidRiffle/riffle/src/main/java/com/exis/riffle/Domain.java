package com.exis.riffle;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/23/16.
 *
 * See here for distribution: http://inthecheesefactory.com/blog/how-to-upload-library-to-jcenter-maven-central-as-dependency/en
 */
public class Domain {
    private Mantle.Domain mantleDomain;

    /* Constructurs */
    public Domain(String name) {
        mantleDomain = Mantle.NewDomain(name);
    }

    public Domain(String name, Domain superdomain) {
        mantleDomain = superdomain.mantleDomain.Subdomain(name);
    }


    public void Subscribe(String endpoint) {
//        mantleDomain.Subscribe(endpoint);
    }

    public void Register(String endpoint) {
//        mantleDomain.Register(endpoint);
    }

    public void Publish(String endpoint) {
//        mantleDomain.Publish(endpoint);
    }

    public void Call(String endpoint) {
//        mantleDomain.Call(endpoint);
    }

    public void Unsubscribe(String endpoint) {
//        mantleDomain.Unsubscribe(endpoint);
    }

    public void Unregister(String endpoint) {
//        mantleDomain.Unregister(endpoint);
    }

    public void Leave() {
        mantleDomain.Leave();
    }
}
