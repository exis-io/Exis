package io.exis.cards.cards;

import android.util.Log;
import com.exis.riffle.Domain;
import java.util.ArrayList;

/**
 * Player.java
 * Controller for a player
 *
 * All players are PG13 as of Dec 17
 *
 * TODO implement pub to reject & choose
 *
 * Created by luke on 10/13/15.
 */
public class Player {

//    private int ID;
    private String playerID;
    private ArrayList<Card> hand;
    private ArrayList<Card> answers;
    private boolean isCzar;
    private int duration;
    private int score;
    private String question;
    private String winnerID;
    private String winningCard;
    private Object ret;
    private Card nextCard;
    public Card picked;
    boolean dummy;
    Domain riffle;
//    Domain dealerDomain;

    GameActivity activity;
    private Receiver playerDomain;

    public Player(String name, Domain app){
        playerDomain = new Receiver(name, app);
        playerDomain.player = this;

        //this.ID = ID;
        playerID = name;
        hand = new ArrayList<>();
        score = 0;
        dummy = false;
    }// end constructor

    // constructor for dummies
    public Player(){
        int ID = Exec.getNewID();
        playerID = "dummy" + ID;
        hand = new ArrayList<>();
        score = 0;
        dummy = true;
    }// end dummy constructor

    // Exec calls
    public void join(){
        playerDomain.join();
    }

    //add a card to player's hand
    public Object draw(String card){
        hand.add(new Card(card));
        return null;
    }//end addCard method

    // calls dealer::pick
    public void pick(){
        if(dummy) return;

        if(picked == null) {
            if (isCzar){
                picked = answers.get(0);
            }else {
                picked = hand.get(0);
            }
        }

        if(isCzar){
            Log.i("player", "calling chose with card " + picked.getText());
            riffle.call("chose", picked.getText());
        }else {
            Log.i("player", "calling pick with card " + picked.getText());
            riffle.call("pick", picked.getText()).then(String.class, (c) -> {
                Log.i("player", "received new card " + c + " from dealer");
                hand.add(new Card(c));
                hand.remove(picked);
                activity.runOnUiThread(()->{
                    Log.i("pick", "refreshing cards with pile " + Card.printHand(hand));
                    activity.refreshCards(hand);
                });
            });
        }

        picked = null;
    }// end pick method

    public ArrayList<Card> hand(){
        return this.hand;
    }//end getCards method

    public Domain domain(){
        return this.playerDomain;
    }

    public String getWinner(){
        return winnerID;
    }

    public String playerID(){
        return playerID;
    }

    public ArrayList<Card> answers(){
        if(answers == null){
            Log.wtf("player", "answers is null!");
            answers = new ArrayList<>();
            for(int i=0; i<5; i++){
                answers.add(Dealer.generateAnswer());
            }
        }
        return answers;
    }

    public boolean isCzar(){
        return this.isCzar;
    }

    public void setCzar(boolean isCzar){
        this.isCzar = isCzar;
    }

    public void setHand(ArrayList<Card> hand){
        this.hand = hand;
    }

    public void setRiffle(Domain riffleDomain){
        this.riffle = riffleDomain;
    }

    public void setPicked(int pos){
        picked = hand.get(pos);
    }

    public void addPoint(){
        score++;
    }

    public String question(){
        if(question == null || question.equals("")) {
            return Dealer.generateQuestion().getText();
        }else{
            return question;
        }
    }

    public void leave(){
        riffle.call("leave", this);
        playerDomain.leave();
        playerDomain = null;
    }

    // Receiver handles riffle calls
    private class Receiver extends Domain{
        private Player player;

        public Receiver(String name, Domain superdomain) {
            super(name, superdomain );
        }

        @Override
        public void onJoin(){
            String TAG = "Player::onJoin()";
            activity.player = player;

            register("draw", String.class, Object.class, (c)->{player.draw(c); return null;});
            riffle.subscribe("joined", String.class, activity::addPlayer);
            riffle.subscribe("left", String.class, activity::removePlayer);

            riffle.subscribe("answering", String.class, String.class, Integer.class,
                    (currentCzar, questionText, duration) -> {
                        Log.i("answering sub:", "currentCzar = " + currentCzar +
                                "\nquestionText = " + questionText +
                                "\nduration = " + duration);

                        player.isCzar = (currentCzar.equals(playerID));
                        activity.currentCzar = currentCzar;
                        player.question = questionText;
                        player.duration = duration;
                        activity.runOnUiThread(activity::setQuestion);
                    });

            riffle.subscribe("picking", String.class, Integer.class,
                    (answers, duration) -> {
                        String[] arr = Card.deserialize(answers, String[].class);
                        Log.i("picking sub: ", "answers = " + Card.printHand(arr) +
                                "\nduration = " + duration);
                        player.answers = Card.buildHand(arr);
                        player.duration = duration;
                        activity.runOnUiThread(() -> activity.refreshCards(player.answers));
                    });

            riffle.subscribe("scoring", String.class, String.class, Integer.class,
                    (winnerID, winningCard, duration) -> {
                        Log.i("scoring sub", "winnerID = " + winnerID +
                                "\nwinningCard = " + winningCard +
                                "\nduration = " + duration);

                        player.winnerID = winnerID;
                        player.winningCard = winningCard;
                        player.duration = duration;
                    });

            Object[] playObject = GameActivity.exec.play();

            if(playObject == null){
                Log.wtf(TAG, "play object is null!");
            }

            activity.onPlayerJoined(playObject);
        }// end onJoin method
    }// end Receiver subclass
}// end Player class

