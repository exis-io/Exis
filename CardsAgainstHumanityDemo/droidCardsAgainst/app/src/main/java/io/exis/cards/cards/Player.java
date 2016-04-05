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
    private String dealerDomain;
    private String question;
    private String winnerID;
    private String winningCard;
    private Object ret;
    private Card nextCard;
    public Card picked;
    boolean dummy;

    GameActivity activity;
    Exec exec;
    private Receiver playerDomain;

    public Player(String name, Domain app){
        exec = new Exec();
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
    public Object draw(Card card){
        hand.add(card);
        return null;
    }//end addCard method

    // dealer calls this method on player
    public Card pick(Card newCard){
        if(dummy){
            picked = hand.get(0);
        }
        hand.add(newCard);
        hand.remove(picked);
        return picked;
    }// end pick method

    public ArrayList<Card> hand(){
        return this.hand;
    }//end getCards method

    public String getWinner(){
        return winnerID;
    }

    public String playerID(){
        return playerID;
    }

    public ArrayList<Card> answers(){
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

    public void setDealer(String dealerDomain){
        this.dealerDomain = dealerDomain;
    }

    // removes card from player's hand
    public boolean removeCard(Card card){
        boolean removed;
        removed = hand.remove(card);
        return removed;
    }// end removeCard method

    public void setPicked(int pos){
        picked = hand.get(pos);

        if(GameActivity.phase.equals("choosing")){
//            playerDomain.publish("chose", picked);
            GameActivity.dealer.danger_pub_chose(picked);
        }else{ // picking phase
            playerDomain.publish("picked", picked);
            GameActivity.dealer.danger_pub_picked(picked);
        }
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
        playerDomain.call("leave", this);
        playerDomain.leave();
    }

    public void danger_pub_answering(Player currentCzar, String questionText, int duration){
//        Log.i("danger answering sub", "received question " + questionText);
        this.isCzar = ( currentCzar.playerID().equals(playerID) );
        this.question = questionText;
        this.duration = duration;
    }

    // executed
    public void danger_pub_picking(String[] answers, int duration){
//        Log.i("danger picking sub", "received answers " + Card.printHand(answers));
        this.answers = Card.buildHand(answers);
        this.duration = duration;
        activity.runOnUiThread(() -> {
            Log.i("player", "refreshing cards with answers");
            activity.refreshCards(this.answers);
        });
    }

    // executed at end of scoring phase
    public void danger_pub_scoring(String winnerID, String winningCard, int duration){
//        Log.i("danger scoring sub", "winning card " + winningCard);
        this.winnerID = winnerID;
        this.winningCard = winningCard;
        this.duration = duration;

        activity.runOnUiThread(()->{
            Log.i("player", "setting question");
            activity.setQuestion();
        });
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

            register("draw", Card.class, Object.class, player::draw);
            register("pick", Card.class, Card.class, player::pick);
            subscribe("joined", String.class, activity::addPlayer);
            subscribe("left", String.class, activity::removePlayer);

            subscribe("answering", Player.class, String.class, Integer.class,
                    (currentCzar, questionText, duration) -> {
                        Log.i("answering sub", "received question " + questionText);

                        player.isCzar = (currentCzar.playerID().equals(playerID));
                        activity.currentCzar = currentCzar;
                        activity.setPlayerBackgrounds();
                        player.question = questionText;
                        player.duration = duration;
                        activity.setQuestion();
                    });

            subscribe("picking", String[].class, Integer.class,
                    (answers, duration) -> {
                        Log.i("picking sub", "received answers " + Card.printHand(answers));
                        player.answers = Card.buildHand(answers);
                        player.duration = duration;
                        activity.runOnUiThread(() -> activity.refreshCards(player.answers));
                    });

            subscribe("scoring", String.class, String.class, Integer.class,
                    (winnerID, winningCard, duration) -> {
                        Log.i("scoring sub", "winning card " + winningCard);
                        player.winnerID = winnerID;
                        player.winningCard = winningCard;
                        player.duration = duration;
                    });

            Object[] playObject = GameActivity.exec.play();       // TODO

            if(playObject == null){
                Log.wtf(TAG, "play object is null!");
            }

            player.hand = Card.buildHand( (String[])playObject[0] );
            setDealer((String)playObject[3]);

            activity.onPlayerJoined(playObject);
        }

    }
}// end Player class

