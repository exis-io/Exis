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
import com.exis.riffle.Model;
import com.exis.riffle.Riffle;
import com.exis.riffle.Utils;


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
//
//        subscribe("sub", () -> {
//            Log.d(TAG, "I have a publish!");
//            return "Publish Received!";
//        });

        // Bootstrap the sender
        parent.sender2.join();
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
    }
}








