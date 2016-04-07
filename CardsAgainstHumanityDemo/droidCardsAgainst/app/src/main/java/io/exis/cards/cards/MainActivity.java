package io.exis.cards.cards;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Scanner;

public class MainActivity extends Activity {
    public static boolean online = false;
    private static Context context;
    private static ArrayList<Card> answers;
    private static ArrayList<Card> questions;
    private static Typeface LibSans;
    private static Typeface LibSansBold;
    private static Typeface LibSansItalic;
    private static String screenName;
    private static TextView screenNameDisplay;
    SharedPreferences preferences;

    Button gameButton;
    Button nameButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        MainActivity.context = getApplicationContext();
        online = false;
        screenName = "";

        //set typefaces
        LibSans = Typeface.createFromAsset(getAssets(),"LiberationSans-Regular.ttf");
        LibSansBold = Typeface.createFromAsset(getAssets(),"LiberationSans-Bold.ttf");
        LibSansItalic = Typeface.createFromAsset(getAssets(),"LiberationSans-Italic.ttf");

        gameButton  = (Button) findViewById(R.id.button);
        gameButton.setTypeface(LibSansBold);
        nameButton = (Button) findViewById(R.id.name_button);
        screenNameDisplay = (TextView) findViewById(R.id.screenname);
        screenNameDisplay.setTypeface(LibSansBold);
        screenNameDisplay.setOnClickListener(this::startNameActivity);

        questions = Card.questions();
        answers = Card.answers();
    }

    @Override
    protected void onStart(){
        super.onStart();
        preferences = PreferenceManager.getDefaultSharedPreferences(context);
    }

    @Override
    protected void onResume(){
        super.onResume();
        preferences = PreferenceManager.getDefaultSharedPreferences(context);
        if(screenName.equals("")){
            screenName = preferences.getString("screenName", "");
            screenNameDisplay.setVisibility(View.INVISIBLE);
        } else {
            String name = getString(R.string.screen_name, screenName);
            screenNameDisplay.setText(name);
            screenNameDisplay.setVisibility(View.VISIBLE);
        }
        Log.i("MainActivity", "loaded screen name " + screenName);
    }

    @Override
    protected void onPause(){
        super.onPause();

        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("screenName", screenName);
        editor.apply();
    }

    public void startNameActivity(View view) {
        Log.i("startNameActivity", "name = " + screenName);
        Intent intent = new Intent(view.getContext(), NameActivity.class);
        intent.putExtra("key_screen_name", screenName);
        view.getContext().startActivity(intent);
    }

    public void startGameActivity(View view) {
        Intent intent = new Intent(view.getContext(), GameActivity.class);
        intent.putExtra("key_screen_name", screenName);
        view.getContext().startActivity(intent);
    }

    public static Typeface getTypeface(String tf){
        if(tf.equals("LibSans")){
            return LibSans;
        }
        if(tf.equals("LibSansBold")){
            return LibSansBold;
        }
        if(tf.equals("LibSansItalic")){
            return LibSansItalic;
        }
        //default to returning regular
        return LibSans;
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);

        //savedInstanceState.putInt("points", points);
    }

    @Override
    protected void onStop(){
        super.onStop();
    }//end onStop method

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    public static Context getAppContext(){
        return MainActivity.context;
    }

    //load file into string and return it
    public static String getCardString(String name){
        String cardString = "";
        if(name.equals("q13")){
            for(int i=1; i<=6; i++){
                int resID = context.getResources().getIdentifier("q" + i, "raw", context.getPackageName());
                Scanner fileIn = new Scanner(context.getResources().openRawResource(resID));
                cardString += fileIn.useDelimiter("\\Z").next();
            }
        }else{
            for(int i=1; i<=15; i++){
                int resID = context.getResources().getIdentifier("a" + i, "raw", context.getPackageName());
                Scanner fileIn = new Scanner(context.getResources().openRawResource(resID));
                cardString += fileIn.useDelimiter("\\Z").next();
            }
        }

        return cardString;
    }//end getCardString method

    public static void setScreenName(String name){
        screenName = name;
    }

    public static ArrayList<Card> getQuestions(){
        return questions;
    }

    public static ArrayList<Card> getAnswers(){
        return answers;
    }
}
