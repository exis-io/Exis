package io.exis.cards.cards;

import java.util.ArrayList;
import java.util.Collections;

import android.content.Context;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.exis.riffle.Domain;
import com.exis.riffle.Riffle;

/**
 * Dealer.java
 * Manages decks and player points
 * TODO register methods joined and closed
 *
 * Created by luke on 10/13/15.
 */
public class Dealer extends Domain{

    final int ROOMCAP = 5;
    private ArrayList<Player> players;                      // keep track of players playing
    private ArrayList<Card> answers;                        // cards sent to czar
    private static ArrayList<Card> questionDeck;
    private static ArrayList<Card> answerDeck;
    private String phase;
    private static Player winner;                           // winner
    private static Card winningCard;
    private Card questionCard;                              // always know question card
    private String dealerID;
    int czarNum;
    private int dummyCount;
    private int playerCount;
    private int duration;
    private Handler handler;
    public Runnable runnable;
    Domain riffle;

    private Player player;

    public Dealer(int ID, Domain domain, Domain riffle){
        super("dealer" + ID, domain);
        this.riffle = riffle;
        dealerID = ID + "";
        czarNum = 0;
        players  = new ArrayList<>();
        answerDeck = MainActivity.getAnswers();
        questionDeck = MainActivity.getQuestions();
        questionCard = generateQuestion();

        answers = new ArrayList<>();
        dummyCount = 0;
        playerCount = 0;
        duration = 15;
        phase = "answering";

        handler = GameActivity.handler;
    }//end Dealer constructor

    // riffle calls
    @Override
    public void onJoin(){
        Log.i("dealer onJoin", "entering method");

        register("leave", String.class, Object.class, (p) -> {
            return this.leave(p);
        });
        register("pick", String.class, String.class, this::pick);

        Log.i("dealer::onJoin", player.playerID() + " joining");
        player.join();
    }

    public String ID(){
        return this.dealerID;
    }

    public void addPlayer(Player player){
        //if max capacity exceeded
        if(full()){
            Log.i("dealer", "game is full");
            if(player.dummy){
                return;
            }else{
                removeDummy();
                Log.i("dealer", "adding player " + player.playerID());
                addPlayer(player);
            }
        }

        //deal them 5 cards
        for(int i=0; i<5; i++){
            dealCard(player);
        }

        if(!player.dummy) {
            playerCount++;
            this.player = player;
            player.domain().subscribe("picked", String.class, (c) -> {
                Log.i("picked listener", "received card " + c);
                answers.add(new Card(c));
            });

            player.domain().subscribe("chose", String.class, (c) -> {
                Log.i("choose listener", "received card " + c);
                winningCard = new Card(c);
            });
        }
        players.add(player);
        publish("joined", player.playerID());
    }//end addPlayer method

    // returns current czar
    private Player czar(){
        return players.get(czarNum);
    }

    public Card dealCard(Player player){

        Card card = generateAnswer();                       //generate new card to give to player

        if(!player.dummy) {
            riffle.call("draw", card.getText());
        }else{
            player.draw(card.getText());                            //add card to player's hand
        }
        return card;
    }//end dealCard method

    public boolean full() {
        return players.size() == ROOMCAP;
    }

    public static Card generateQuestion(){
        Collections.shuffle(questionDeck);
        return questionDeck.get(0);
    }//end generateCard method

    public static Card generateAnswer(){
        Collections.shuffle(answerDeck);
        return answerDeck.get(0);
    }//end generateCard method

    public ArrayList<Card> getNewHand(){
        ArrayList<Card> hand = new ArrayList<>();
        Card newCard = generateAnswer();
        for(int i=0; i<5; i++){
            while(hand.contains(newCard)) {
                newCard = generateAnswer();
            }

            hand.add(generateAnswer());
        }

        return hand;
    }// end getNewHand method

    public Player[] getPlayers(){
        return players.toArray(new Player[players.size()]);
    }//end getPlayers method

    public Card getQuestion(){
        if(questionCard == null){
            questionCard = generateQuestion();
        }
        return questionCard;
    }

    public void prepareGame(){
        if(questionDeck == null) {
            questionDeck = MainActivity.getQuestions();                //load all questions
        }
        if(answerDeck == null) {
            answerDeck = MainActivity.getAnswers();                    //load all answers
        }
        Log.i("prepareGame", "questions has size " + questionDeck.size() +
                ", answers has size " + answerDeck.size());
    }

    // add dummies to fill room
    public void addDummies(){
        while(players.size() < ROOMCAP){
            addPlayer(new Player());
            dummyCount++;
        }
    }

    private void removeDummy(){
        for(Player p: players){
            if(p.dummy){
                players.remove(p);
                return;
            }
        }
    }

    public Object leave(String leavingPlayer){
        for(Player p: players){
            if(p.playerID().equals(leavingPlayer)){
                players.remove(p);
            }
        }
        if(playerCount == 0){
            Exec.removeDealer(this);
        }
        publish("left", leavingPlayer);
        return null;
    }//end remove player method

    // deal cards to all players
    public void setPlayers(){
        for(int i=0; i<players.size(); i++){
            //give everyone 5 cards
            while(players.get(i).hand().size() < 5){
                dealCard(players.get(i));
            }
        }
    }//end setPlayers method

    // dummies pick random winner
    private void setWinner(){
        int num = (int) (Math.random()*5);

        if(!players.get(num).isCzar()){
            winningCard = answers.get(num);
            winner = players.get(num);
        }else{
            setWinner();
        }
    }

    //update czar to next player
    private void updateCzar(){
        players.get(czarNum).setCzar(false);
        czarNum++;
        czarNum = czarNum % players.size();
        players.get(czarNum).setCzar(true);
    }// end updateCzar method

    public Object[] play(){
        if(getPlayers().length < ROOMCAP){
            addDummies();
        }

        return new Object[]{
                Card.handToStrings( getNewHand() ),             // String[] cards
                getPlayers(),                                   // Player[] players
                phase,                                          // String   state
                dealerID};                                      // String   roomName
    }

    public String pick(String picked){
        answers.add(new Card(picked));
        Log.i("dealer", "received answer " + picked + " from player");

        // start next phase upon receipt of card

        return generateAnswer().getText();
    }

    public void start(){
        //fill room with players
        addDummies();
        updateCzar();
        int delay = 15000;
        runnable = new Runnable(){
            public void run() {
                Log.i("dealer", "starting " + phase + " phase");
                playGame(phase);
                handler.postDelayed(this, delay);
            }
        };
        handler.postDelayed(runnable, 0);
    }//end start method

    /* Main game logic.
     *
     * Answering - players submit cards to dealer
     * Picking - Czar picks winner
     * Scoring - Dealer announces winner
     *
     */
    private void playGame(String type){
        String TAG = "playGame";

        switch(type){
            case "answering":
                updateCzar();
                questionCard = generateQuestion();              //update question

                Log.i(TAG, "publishing [answering, \n" +
                        czar().playerID() + ", \n" +
                        getQuestion().getText() + ", \n" +
                        duration + "]");
                publish("answering", czar().playerID(), getQuestion().getText(), duration);

                setPlayers();                    // deal cards back to each player
                phase = "picking";
                break;
            case "picking":
                answers.clear();
                Log.i(TAG, "gathering answers from " + players.size() + " players");
                for(Player p : players){
                    if(p.dummy) {
                        answers.add(generateAnswer());
                    }
                }

                while(answers.size() < 5){
                    Log.wtf("padding answers pile", "answers had size " + answers.size());
                    answers.add(generateAnswer());
                }

                ArrayList<Card> a = answers;
                Log.i(TAG, "publishing [picking, \n" +
                        Card.printHand(a) +
                        duration + "]");
                publish("picking", Card.serialize(Card.handToStrings(answers)), duration);

                phase = "scoring";
                break;
            case "scoring":
                setWinner();

                Log.i(TAG, "publishing [scoring, " +
                        winner.playerID() + ", " +
                        winningCard.getText() + ", " +
                        duration + "]");
                publish("scoring", winner.playerID(), winningCard.getText(), duration);

                answers.clear();
                phase = "answering";
                break;
        }
    }// end playGame method
}//end Dealer class