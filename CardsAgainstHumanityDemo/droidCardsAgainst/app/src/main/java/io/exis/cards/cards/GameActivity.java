package io.exis.cards.cards;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.content.Context;
import android.widget.Toast;

import com.exis.riffle.Domain;
import com.exis.riffle.Riffle;

import java.util.ArrayList;

/**
 * GameActivity.java
 *
 * Manages game screen
 *
 * Created by luke on 10/22/15.
 */
public class GameActivity extends Activity {
    public int points;
    public Player player;
    public static Dealer dealer;
    public static Exec exec;
    public static Player currentCzar;
    public static Handler handler;
    public static String phase;
    public Player[] players;
    public String state;
    public String roomName;

    private Context context;
    private ProgressBar progressBar;
    private boolean answerSelected;
    private Card chosen;
    private ArrayList<Card> forCzar;
    private GameTimer timer;
    private String screenName;

    RelativeLayout layout;
    TextView infoText;
    ArrayList<TextView> cardViews;
    static ArrayList<TextView> playerInfos;

    public GameActivity(){
        Log.i("GameActivity", "entered constructor");
        Riffle.setFabricDev();
//        Riffle.setLogLevelInfo();
        Riffle.setCuminOff();

        this.context = MainActivity.getAppContext();
        timer = new GameTimer(15000, 10);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.i("Game activity", "entering onCreate()");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_game);

        cardViews = new ArrayList<>();
        playerInfos = new ArrayList<>();

        // add 5 textviews to cardViews Array List
        for(int i=0; i<5; i++){
            String str = "card" + (i + 1);
            int resID = context.getResources().getIdentifier(str, "id", context.getPackageName());
            TextView textView = (TextView) findViewById(resID);
            textView.setTypeface(MainActivity.getTypeface(""));

            final int index = i;
            textView.setOnClickListener(view -> submitCard(index, view));

            cardViews.add(i, textView);
        }// end for loop

        // add 4 textviews to playerInfos
        for(int i=0; i<4; i++){
            String str = "player_info" + i;
            int resID = context.getResources().getIdentifier(str, "id", context.getPackageName());
            TextView textView = (TextView) findViewById(resID);
            textView.setTypeface(MainActivity.getTypeface(""));
            playerInfos.add(textView);
        }

        layout = (RelativeLayout) findViewById(R.id.game_bg);
        infoText = (TextView) findViewById(R.id.info);
        progressBar = (ProgressBar) findViewById(R.id.progress);
        infoText.setTypeface(MainActivity.getTypeface("LibSansItalic"));

        handler = new Handler();
    }// end onCreate method

    @Override
    public void onStart(){
        Log.i("Game activity", "entering onStart()");
        super.onStart();

        Bundle bundle = getIntent().getExtras();
        screenName = bundle.getString("key_screen_name", "");

        Log.i("screen name", screenName);

        if(screenName.equals("")){
            screenName = "player" + Exec.getNewID();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        String TAG = "GameActivity::onResume";

        Log.i(TAG, "creating Exec instance");
        exec = new Exec();

        Domain app = new Domain("xs.damouse.CardsAgainst");
        Log.i(TAG, "screenname=" + screenName);
        Player player = new Player(screenName, app);
        player.activity = this;
        exec.setPlayer(player);
        exec.join();
    }//end onResume method

    @Override
    public void onPause(){
        super.onPause();

//         save points here

        timer.cancel();
        handler.removeCallbacks(dealer.runnable);
        player.leave();
        dealer = null;
        exec = null;
        timer = null;
    }//end onPause method

    @Override
    protected void onStop(){
        super.onStop();
    }//end onStop method

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    public void onBackPressed(){
        this.finish();
        super.onBackPressed();
    }

    public void playGame(){
        answerSelected = false;
        setQuestion();

        timer.setType("answering");
        timer.start();
    }//end playGame method

    // called by Player after join
    public void onPlayerJoined(Object[] play){
        String TAG = "onPlayerJoined()";
        phase = "answering";
        int pos = 0;
        try {
            player.setHand(Card.buildHand((String[]) play[0]));
            this.players = (Player[]) play[1];

            try {
                // display players in game
                for (Player p : this.players) {
                    if (p != null && !this.player.playerID().equals(p.playerID())) {
                        final int posF = pos;
                        runOnUiThread(() -> {
                            String str = p.playerID();
                            playerInfos.get(posF).setText(str);
                            if (currentCzar != null && str.equals(currentCzar.playerID())) {
                                playerInfos.get(posF).setBackgroundColor(Color.parseColor("#00a2ff"));
                            }else{
                                playerInfos.get(posF).setBackgroundColor(Color.parseColor("#005688"));
                            }
                        });
                        pos++;
                    }
                }
            }catch(NullPointerException e){
                Log.wtf("onPlayerJoined", "caught null players array");
                e.printStackTrace();
            }
            this.state = (String) play[2];
            this.roomName = (String) play[3];
        }catch(NullPointerException e){
            Log.wtf(TAG, "null pointer in play object");
            e.printStackTrace();
        }

        this.runOnUiThread(() -> {
            setQuestion();                              //set question TextView
            refreshCards(player.hand());
            playGame();
        });
    }//end onPlayerJoin method

    public void setQuestion(){
        String questionText;
        questionText = player.question();

        TextView textView = (TextView) findViewById(R.id.question);
        textView.setText(questionText);
        textView.setTypeface(MainActivity.getTypeface("LibSansBold"));
    }//end setQuestion method

    //Sets card faces to answers
    public void refreshCards(ArrayList<Card> pile){
        //change card texts to text of cards in hand
        for(int i=0; i<5; i++){
            cardViews.get(i).setText( pile.get(i).getText() );
            if(player.picked != null
                    && !phase.equals("answering")
                    && !player.isCzar()
                    && pile.get(i).getText().equals( player.picked.getText())){
                cardViews.get(i).setBackgroundColor(Color.parseColor("#8ad4ff"));    // light blue
            }else{
                cardViews.get(i).setBackgroundColor(Color.WHITE);
            }
        }
    }//end setAnswers method

    public void addPlayer(String player){
        runOnUiThread(() -> {
            playerInfos.get( playerInfos.size() - 1 ).setText(player);
            if(player.startsWith("dummy")){
                playerInfos.get(3).setBackgroundColor(Color.parseColor("#551A8B"));
            }
        });
    }

    public void removePlayer(String player){
        for(TextView t : playerInfos){
            if(t.getText().equals(player)){
                runOnUiThread(()->t.setText(""));
            }
        }
    }

    private void submitCard(int num, View view){
        String TAG = "submitCard";
        if(player.isCzar() && phase.equals("picking") ||
                !player.isCzar() && phase.equals("answering")) {
            player.setPicked(num);
            setBackgrounds(num, view);
            answerSelected = true;
        }else{
            Log.i(TAG, "player is czar: " + player.isCzar());
            Log.i(TAG, "phase: " + phase);
        }
    }

    // card c gets colored background
    private void setBackgrounds(int c, View v){
        v.setBackgroundColor(Color.parseColor("#ff00a2ff"));        // blue
        ((TextView) v).setTextColor(Color.WHITE);

        // all other card backgrounds white
        for(int i=0; i<5; i++){
            if(i != c){
                cardViews.get(i).setBackgroundColor(Color.WHITE);
            }
        }
    }//end setBackgrounds method

    // set all backgrounds to white
    private void resetBackgrounds(){
        for(TextView v : cardViews){
            v.setBackgroundColor(Color.WHITE);
            v.setTextColor(Color.BLACK);
        }
    }

    public void setPlayerBackgrounds(){
        for(TextView t : playerInfos){
            if( t.getText().equals( currentCzar.playerID() )){
                runOnUiThread(() -> t.setBackgroundColor(Color.parseColor("#00a2ff")));
            }else{
                runOnUiThread(() -> t.setBackgroundColor(Color.parseColor("#005688")));
            }
        }
    }

    private class GameTimer extends CountDownTimer{
        private GameTimer next;
        private String type;

        public GameTimer(long startTime, long interval){
            super(startTime, interval);
        }

        @Override
        public void onFinish(){
            progressBar.setProgress(progressBar.getMax());
            switch(type){
                case "answering":                           //next phase will be picking
                    try {
                        refreshCards(player.answers());
                    }catch(NullPointerException e){
                        Log.wtf("GameActivity", "answers array is null");
                    }
                    if(player.isCzar()){
                        infoText.setText(R.string.answeringInfo);
                        forCzar = player.answers();
                        chosen = forCzar.get(0);            //default submit first card
                    }else{
                        resetBackgrounds();
                        infoText.setText(R.string.pickingInfo);
                        if(!answerSelected){
                            submitCard(0, cardViews.get(0));
                        }
                    }

                    answerSelected = false;
                    phase = "picking";
                    setNextTimer("picking");
                    break;
                case "picking":                             //next phase will be scoring
                    infoText.setText(R.string.scoringInfo);
                    resetBackgrounds();
                    refreshCards(player.hand());
                    phase = "scoring";
                    setNextTimer("scoring");
                    break;
                case "scoring":                                 //next phase will be answering
                    setQuestion();                              //update question card
                    if(player.isCzar()){
                        resetBackgrounds();
                        infoText.setText(R.string.playersPickingInfo);
                    }else{
                        infoText.setText(R.string.answeringInfo);
                    }
                    String winnerID = player.getWinner();             //give point if player is winner
                    if(winnerID != null && winnerID.equals(player.playerID())){
                        Toast.makeText(context, "You won this round!", Toast.LENGTH_SHORT).show();
                        player.addPoint();
                    }
                    Log.i("Player's cards", Card.printHand( player.hand() ));

                    refreshCards(player.hand());
                    phase = "answering";
                    setNextTimer("answering");
                    break;
            }//end switch
            Log.i("game timer", "beginning phase " + phase);
            next.start();
        }// end onFinish method

        @Override
        public void onTick(long millisUntilFinished){
            //TODO add sexier progress animation

            //set chronometer width proportionally to time remaining
            long timeRemaining = (millisUntilFinished / 1000);
            int progress = (int) (progressBar.getMax() * timeRemaining / 15);

            progressBar.setProgress(progress);
        }//end onTick method

        public void setType(String timerType){
            type = timerType;
        }

        private void setNextTimer(String nextType){
            // TODO synchronization may be a problem
            next = new GameTimer(15000, 10);
            next.setType(nextType);
        }
    }//end GameTimer subclass
}//end GameActivity class