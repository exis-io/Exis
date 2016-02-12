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
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        fab.setOnClickListener((button) -> {
            riffleSender();
        });

        TextView textview = (TextView) findViewById(R.id.mytextview);
        textview.setText("Reeefle");

        // I cant believe I've written this line.
        // TypeResolver
        System.setProperty("java.version", "1.8");
        Log.d(TAG, "Java version: " + System.getProperty("java.version"));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    Domain app = new Domain("xs.damouse");
    Receiver receiver = new Receiver("alpha", app);
    Sender sender = new Sender("beta", app);

    Domain app2 = new Domain("xs.damouse");
    Receiver receiver2= new Receiver("alpha", app2);
    Sender sender2 = new Sender("beta", app2);

    void riffleSender() {
        Riffle.setFabricDev();
        Riffle.setLogLevelDebug();
        Riffle.setCuminOff();

        Riffle.debug("Starting riffle tests!");

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

        register("reg", String.class, (name) -> {
            Log.d(TAG, "I have a call from: " + name);
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

        parent.receiver2.publish("sub", 1, 2, 3);
        parent.receiver2.call("reg", "Johnathan");
    }
}








