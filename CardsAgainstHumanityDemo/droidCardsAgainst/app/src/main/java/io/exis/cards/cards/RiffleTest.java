package io.exis.cards.cards;

import android.util.Log;

import com.exis.riffle.Domain;
import com.exis.riffle.Riffle;

/**
 * Created by luke on 4/7/16.
 */
public class RiffleTest {

    Domain app, app2;
    Sender sender, sender2;
    Receiver receiver, receiver2;

    public RiffleTest(){
        app = new Domain("xs.damouse");
        receiver = new Receiver("alpha", app);
        sender = new Sender("beta", app);

        app2 = new Domain("xs.damouse");
        receiver2= new Receiver("alpha", app2);
        sender2 = new Sender("beta", app2);
    }

    public void test() {
        Riffle.setFabricDev();
        Riffle.setLogLevelDebug();
        Riffle.setCuminOff();

        Riffle.debug("Starting riffle tests!");

        receiver.parent = this;
        sender2.parent = this;

        receiver.join();
    }
}// end RiffleTest class

class Receiver extends Domain {
    private static final String TAG = "Receiver";
    public RiffleTest parent;

    // I REALLY have to do this? Come on, java
    // Create these without needing to override the default constructor...
    public Receiver(String name) {
        super(name);
    }

    public Receiver(String name, Domain superdomain) {
        super(name, superdomain );
    }

    @Override
    public void onJoin() {
        Log.d(TAG, "Receiver joined!");

        subscribe("sub", Integer.class, Integer.class, Integer.class, (a, b, c) -> {
            Log.d(TAG, "I have a publish: " + a + ", " + b + ", " + c);
        });

        register("reg", String.class, String.class, (name) -> {
            Log.d(TAG, "I have a call from: " + name);
            return "Hey. caller!";
        });

        // Cool. I guess? It would be really nice to do away with the ".class" here
        subscribe("vich", Boolean.class, this::someHandler);

        // Bootstrap the sender
        parent.sender2.join();
    }

    void someHandler(Boolean c) {
        Log.d(TAG, "These are cool jeans: " + c);
    }
}

class Sender extends Domain {
    private static final String TAG = "Sender";
    public RiffleTest parent;

    // I REALLY have to do this? Come on, java
    public Sender(String name) {
        super(name);
    }

    public Sender(String name, Domain superdomain) {
        super(name, superdomain );
    }

    @Override
    public void onJoin() {
        Log.d(TAG, "Sender joined!");

        parent.receiver2.publish("sub", new String[]{"a", "b"});

        parent.receiver2.call("reg", "Johnathan").then(String.class, (greeting) -> {
            Log.d(TAG, "I received : " + greeting);
        });
    }
}
