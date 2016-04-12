package luke.com.rifflepub;

import android.animation.Animator;
import android.animation.LayoutTransition;
import android.animation.TimeInterpolator;
import android.content.Context;
import android.graphics.Typeface;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.exis.riffle.Domain;
import com.exis.riffle.Riffle;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    RiffleSession session;
    Domain app;
    ArrayList<RelativeLayout> messageViews = new ArrayList<>();
    TextView textView;
    String sender = "Luke";
    LayoutInflater inflater;
    ViewGroup content;

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

        content = (ViewGroup) findViewById(R.id.messageLayout);
        inflater = (LayoutInflater) getApplicationContext()
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);

        textView = (TextView) findViewById(R.id.textField);
        textView.setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);

        session = new RiffleSession(app);
        session.activity = this;
        session.join();
    }

    public void sendMsg(View view){
        String msg = textView.getText().toString();
        if(msg.equals("")) return;                  // do nothing on empty message

        if(msg.charAt(0) == '@'){                   // PMs
            addText(msg, sender, true);
            String recipient = msg.substring(1, msg.indexOf(' '));
            Log.i("sendMsg", "recipient=" + recipient);
            msg = msg.substring(msg.indexOf(' ') + 1);
            Log.i("sendMsg", "msg=" + msg);
            session.sendPM(msg, recipient);
        } else {                                    // normal messages
            addText(msg, sender, false);
            session.sendMessage(msg);
        }

        textView.setText("");
    }

    public void receiveMsg(String message, String source) {
        addText(message, source, false);
    }

    public Object addPM(String message, String source){
        addText(message, source, true);
        return null;
    }

    /* add message to interface
     *
     * @param   message Message to add
     * @param   source  Who the message came from
     * @param   pm      Whether message is a PM
     */
    private void addText(String message, String source, boolean pm) {
        runOnUiThread(() -> {
            View layout;
            RelativeLayout bubble;
            TextView text;
            RelativeLayout.LayoutParams params;

            if (!source.equals(sender)) {
                layout = inflater.inflate(R.layout.bubble_left, content, false);
                content.addView(layout);
                bubble = (RelativeLayout) findViewById(R.id.protoLeft);
                text = (TextView) findViewById(R.id.protoMsgLeft);
            } else {
                layout = inflater.inflate(R.layout.bubble_right, content, false);
                content.addView(layout);
                bubble = (RelativeLayout) findViewById(R.id.protoRight);
                text = (TextView) findViewById(R.id.protoMsgRight);
            }

            messageViews.add(bubble);
            bubble.setId(View.generateViewId());

            text.setId(View.generateViewId());
            text.setText(message);
            if (pm) {
                text.setTypeface(null, Typeface.BOLD);
            }

            // set card below previous card
            if (messageViews.size() > 1) {
                params = ((RelativeLayout.LayoutParams) bubble.getLayoutParams());
                params.addRule(RelativeLayout.BELOW, messageViews.get(messageViews.size() - 2).getId());
            }

        });
    }// end addCard method

    /*
     * RiffleSession subclass inherits fields of MainActivity class
     */
    private class RiffleSession extends Domain{
        MainActivity activity;

        public RiffleSession(Domain app){
            super("exis", app);
        }

        @Override
        public void onJoin(){
            subscribe("chat", String.class, String.class, activity::receiveMsg);
            register(sender, String.class, String.class, Object.class, (msg, src) -> {
                activity.addPM(msg, src);
                return null;
            });

            register("exis", String.class, String.class, Object.class, (msg, src) -> {
                activity.receiveMsg(msg, "exis");
                return null;
            });
        }

        public void sendMessage(String msg) {
            publish("chat", msg, sender);
        }

        public void sendPM(String msg, String recipient){
            call(recipient, msg, sender);
        }
    }// end RiffleSession subclass
}// end MainActivity class