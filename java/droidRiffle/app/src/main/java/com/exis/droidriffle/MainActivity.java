package com.exis.droidriffle;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import com.exis.riffle.AppDomain;
import com.exis.riffle.Domain;
import com.exis.riffle.Model;
import com.exis.riffle.Riffle;

import java.lang.reflect.Type;


public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";

    // Start riffle inline testing
    // Note that the two-domain setup here is just for testing-- you shouldn't do this!
    AppDomain app = new AppDomain("xs.demo.damouse.dojo");
    Receiver receiver = new Receiver("alpha", app);
    Sender sender = new Sender("beta", app);

    AppDomain app2 = new AppDomain("xs.demo.damouse.dojo");
    Receiver receiver2= new Receiver("alpha", app2);
    Sender sender2 = new Sender("beta", app2);


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Do nothing but start the tests
//        Riffle.setFabricDev();
        Riffle.setLogLevelInfo();

        Riffle.debug("Starting riffle tests");

        receiver.parent = this;
        sender2.parent = this;

//        receiver.join();

        // Auth level 1
//        app.registerDomain("a", "123456778", "asdf@gmail.com", "asdf").then( () -> {
//            Riffle.info("Successfully registered!");
//        }).error( () -> {
//            Riffle.info("Unable to register: ");
//        });

        // Auth level 0
        app.login("d").then( () -> {
            Riffle.info("Successfully registered!");
        }).error( () -> {
            Riffle.info("Unable to register: ");
        });
    }

}

class Receiver extends Domain {
    private static final String TAG = "Receiver";
    public MainActivity parent;

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

        subscribe("sub", Integer.class, (a) -> {
            Log.d(TAG, "I have a publish: " + a);
        });

        subscribe("subscribeModels", Dog.class, (a) -> {
            Log.d(TAG, "I have a dog: " + a);
        });

        register("reg", String.class, String.class, (name) -> {
            Log.d(TAG, "I have a call from: " + name);
            return "Hey. caller!";
        });

        subscribe("vich", Boolean.class, this::someHandler);

        // Bootstrap the sender
//        parent.sender2.join();
    }

    void someHandler(Boolean c) {
        Log.d(TAG, "These are cool jeans: " + c);
    }
}

class Sender extends Domain {
    private static final String TAG = "Sender";
    public MainActivity parent;

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

        parent.receiver2.publish("sub", 1);

        parent.receiver2.publish("subscribeModels", new Dog());

        parent.receiver2.call("reg", "Johnathan").then(String.class, (greeting) -> {
            Log.d(TAG, "I received : " + greeting);
        });
    }
}



