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
    Domain superdomain;
    Domain dealerDomain;
    Dealer dealer;

    public Exec(String name, Domain superdomain, Player player) {
        super(name, superdomain);
        this.superdomain = superdomain;
        this.dealerDomain = new Domain("xs.damouse.CardsAgainst");
        this.player = player;
        dealer = findDealer();
        GameActivity.dealer = dealer;                   // TODO danger, maybe unnecessary
    }

    @Override
    public void onJoin(){
//        register("play", Object[].class, this::play);

        Thread thread = new Thread(){
            public void run(){
                Log.i("Exec", "dealer " + dealer.ID() + " joining");
                dealer.join();
            }
        };
        thread.start();
    }

    public Object[] play(){
        Object[] playObject = dealer.play();
        dealer.start();
        return playObject;
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

        return dealer;
    }// end findDealer method

    public static int getNewID(){
        return (int) (Math.random() * Integer.MAX_VALUE);
    }// end getNewID method

    //create new dealer and add to dealer list
    //return dealer ID
    private Dealer addDealer(){
        Dealer dealer = new Dealer(getNewID(), dealerDomain);
        dealers.add(dealer);
        return dealer;
    }//end addDealer method
}//end Exec class