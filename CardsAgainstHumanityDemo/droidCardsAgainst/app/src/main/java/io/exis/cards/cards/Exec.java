package io.exis.cards.cards;

import android.util.Log;
import com.exis.riffle.Domain;
import java.util.ArrayList;

/**
 * Exec.java
 * Manages creation/deletion of rooms and authentication of users
 *
 * Created by luke on 10/15/15.
 */
public class Exec extends Domain{
    static ArrayList<Dealer> dealers = new ArrayList<>();
    private Player player;

    public Exec() {
        super("Exec", new Domain("xs.damouse.CardsAgainst"));
    }

    @Override
    public void onJoin(){
        register("play", Object[].class, this::play);
        player.join();
    }

    public Object[] play(){
        Dealer dealer = findDealer();
        GameActivity.dealer = dealer;                   // TODO danger
        return dealer.play();
    }

    public void setPlayer(Player p){
        this.player = p;
    }

    public static void removeDealer(Dealer dealer){
        dealers.remove(dealer);
    }

    //finds a dealer not at max capacity
    public Dealer findDealer(){
        String TAG = "Exec::findDealer";
        for(int i=0; i<dealers.size(); i++){
            if(!dealers.get(i).full()){
                return dealers.get(i);
            }
        }

        Dealer dealer = addDealer();
        Log.i(TAG, "found dealer " + dealer.ID());
        dealer.addPlayer(player);
        Log.i(TAG, "added player " + player.playerID());
        dealer.join();
        Log.i(TAG, "dealer " + dealer.ID() + " joining");
        dealer.start();

        return dealer;
    }// end findDealer method

    public static int getNewID(){
        return (int) (Math.random() * Integer.MAX_VALUE);
    }// end getNewID method

    //create new dealer and add to dealer list
    //return dealer ID
    private static Dealer addDealer(){
        Dealer dealer = new Dealer(getNewID());
        dealers.add(dealer);
        return dealer;
    }//end addDealer method
}//end Exec class