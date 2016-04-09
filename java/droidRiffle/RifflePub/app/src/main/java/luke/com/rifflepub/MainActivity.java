package luke.com.rifflepub;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.exis.riffle.Domain;
import com.exis.riffle.Riffle;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    RiffleSession session;
    Domain app;
    ArrayAdapter<String> adapter;
    ArrayList<String> messages = new ArrayList<>();
    ListView list;
    TextView textView;
    String sender = "Luke";

    public MainActivity(){
        app = new Domain("xs.demo");
        sender = "Luke";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Riffle.setFabricDev();
        Riffle.setLogLevelDebug();
        Riffle.setCuminOff();

        list = (ListView) findViewById(R.id.list);
        adapter=new ArrayAdapter<>(this,
                R.layout.list_item,
                R.id.list_content,
                messages);
        list.setAdapter(adapter);
        textView = (TextView) findViewById(R.id.textField);

        session = new RiffleSession(app);
        session.activity = this;
        session.join();
    }

    public void addText(String text, String sender){
        runOnUiThread(() -> {
            Log.i("Main activity", "adding text" + text);
            messages.add(sender + ": " + text);
            adapter.notifyDataSetChanged();
        });
    }

    public void sendMsg(View view){
        String msg = textView.getText().toString();
        session.sendMessage(msg, sender);
        runOnUiThread(() -> {
            Log.i("Main activity", "sending text" + msg);
            messages.add("sent: " + msg);
            adapter.notifyDataSetChanged();
            textView.setText("");
        });
    }

    public void clear(View view){
        messages.clear();
        adapter.notifyDataSetChanged();
    }

    /*
     * RiffleSession subclass inherits fields of MainActivity class
     */
    private class RiffleSession extends Domain{
        Domain app;
        Domain riffle;
        MainActivity activity;

        public RiffleSession(Domain app){
            super("exis", app);
            this.app = app;
            this.riffle = new Domain("exis", app);
        }

        @Override
        public void onJoin(){
            riffle.subscribe("chat", String.class, String.class, activity::addText);
        }

        public void sendMessage(String msg, String sender){
            publish("chat", msg, sender);
        }
    }// end RiffleSession subclass
}// end MainActivity class