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
    private String screenName;
    private static TextView screenNameDisplay;
    SharedPreferences preferences;
    SharedPreferences.Editor editor;

    Button gameButton;
    Button nameButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        MainActivity.context = getApplicationContext();
        online = false;
        screenName = "";

        preferences = getPreferences(MODE_PRIVATE);

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

        Log.d("onResume", "entered onResume");

        try {
            Bundle bundle = getIntent().getExtras();
            screenName = bundle.getString("screenName", "");
        }catch(NullPointerException e){
            screenName = preferences.getString("screenName", "");
            if(screenName.equals("")){
                Log.d("onResume", "unable to load screen name");
                screenNameDisplay.setVisibility(View.INVISIBLE);
            } else {
                String name = getString(R.string.screen_name, screenName);
                screenNameDisplay.setText(name);
                screenNameDisplay.setVisibility(View.VISIBLE);
            }
        }
    }

    @Override
    protected void onPause(){
        super.onPause();

        editor = preferences.edit();
        editor.putString("screenName", screenName);
        editor.apply();
    }

    public void startNameActivity(View view) {
        Intent intent = new Intent(this, NameActivity.class);
        intent.putExtra("screenName", screenName);
        startActivityForResult(intent, 1);
    }
    public void startGameActivity(View view) {
        Intent intent = new Intent(view.getContext(), GameActivity.class);
        intent.putExtra("key_screen_name", screenName);
        view.getContext().startActivity(intent);
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

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == RESULT_OK) {
            this.screenName = data.getStringExtra("screenName");

            if(screenName.equals("")){
                screenNameDisplay.setVisibility(View.INVISIBLE);
            } else {
                String name = getString(R.string.screen_name, screenName);
                screenNameDisplay.setText(name);
                screenNameDisplay.setVisibility(View.VISIBLE);
            }
        }
    }

    public static Context getAppContext(){
        return MainActivity.context;
    }
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
    public static ArrayList<Card> getQuestions(){
        return questions;
    }
    public static ArrayList<Card> getAnswers(){
        return answers;
    }
    public static Typeface getTypeface(String tf){
        switch (tf){
            case "LibSansBold":
                return LibSansBold;
            case "LibSansItalic":
                return LibSansItalic;
            default:
                return LibSans;
        }
    }
}
