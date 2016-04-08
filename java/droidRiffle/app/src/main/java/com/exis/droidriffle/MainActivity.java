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

import com.exis.riffle.Domain;
import com.exis.riffle.Riffle;

import java.lang.reflect.Type;


public class MainActivity extends AppCompatActivity {
    private static final String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Do nothing but start the tests
        riffleSender();
    }

    // Start riffle inline testing
    // Note that the two-domain setup here is just for testing-- you shouldn't do this!
    Domain app = new Domain("xs.damouse");
    Receiver receiver = new Receiver("alpha", app);
    Sender sender = new Sender("beta", app);

    Domain app2 = new Domain("xs.damouse");
    Receiver receiver2= new Receiver("alpha", app2);
    Sender sender2 = new Sender("beta", app2);

    void riffleSender() {
        Riffle.setFabricDev();
        Riffle.setLogLevelInfo();

        Riffle.debug("Starting riffle tests");

        receiver.parent = this;
        sender2.parent = this;

        receiver.join();
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

        register("reg", String.class, String.class, (name) -> {
            Log.d(TAG, "I have a call from: " + name);
            return "Hey. caller!";
        });

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

        parent.receiver2.call("reg", "Johnathan").then(String.class, (greeting) -> {
            Log.d(TAG, "I received : " + greeting);
        });
    }
}








