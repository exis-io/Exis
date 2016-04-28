package io.exis.cards.cards;

import android.app.Activity;
import android.app.ActivityOptions;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

/**
 * Allows user to change screen name
 *
 * Created by luke on 3/30/16.
 */
public class NameActivity extends Activity {

    private EditText nameField;
    private TextView border;
    private String screenName;
    private RelativeLayout background;
    SharedPreferences preferences;
    InputMethodManager mgr;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_name);
        preferences = getPreferences(MODE_PRIVATE);

        background = (RelativeLayout) findViewById(R.id.background);
        nameField = (EditText) findViewById(R.id.name_field);
        nameField.setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        border = (TextView) findViewById(R.id.border);
        mgr = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);

        nameField.setOnClickListener(v -> {
            Log.i("name activity", "onClickListener fired");
            nameField.setText("");
            border.setBackgroundColor(Color.parseColor("#00a2ff"));
        });

        nameField.setOnFocusChangeListener((v, hasFocus) -> {
            if (hasFocus) {
                nameField.setText("");
                border.setBackgroundColor(Color.parseColor("#00a2ff"));
            }else{
                leaveTextField();
            }
        });

        background.setOnClickListener(v -> {
            leaveTextField();
        });

        nameField.setOnKeyListener((v, keyCode, event) -> {
            if ((event.getAction() == KeyEvent.ACTION_DOWN) &&
                    (keyCode == KeyEvent.KEYCODE_ENTER)) {
                leaveTextField();
                return true;
            }
            return false;
        });
    }

    void leaveTextField(){
        nameField.clearFocus();
        mgr.hideSoftInputFromWindow(background.getWindowToken(), 0);
        if (!nameField.getText().toString().equals("") &&
                !nameField.getText().toString().equals("Enter Screen Name")) {
            screenName = nameField.getText().toString();
        }
        border.setBackgroundColor(Color.parseColor("#ffffff"));
    }

    @Override
    public boolean onTouchEvent(MotionEvent event){
        return super.onTouchEvent(event);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Bundle bundle = getIntent().getExtras();
        screenName = bundle.getString("screenName", "");

        if(!screenName.equals("")){
            nameField.setText(screenName);
        }else{
            Log.i("onResume", "Unable to load screen name");
        }
    }

    @Override
    protected void onPause(){
        super.onPause();
    }

    @Override
    protected void onStop(){
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

    }

    @Override
    public void onBackPressed(){
        setName();
        finish();
        if(android.os.Build.VERSION.SDK_INT >= 21) {
            overridePendingTransition(android.R.anim.slide_in_left, android.R.anim.slide_out_right);
        }
    }

    public void backClicked(View view){
        setName();
        finish();
        if(android.os.Build.VERSION.SDK_INT >= 21) {
            overridePendingTransition(android.R.anim.slide_in_left, android.R.anim.slide_out_right);
        }
    }
    void setName(){
        if(!nameField.getText().toString().equals("") &&
                !nameField.getText().toString().equals("Enter Screen Name")) {
            screenName = nameField.getText().toString();
        }

        Intent intent = new Intent();
        intent.putExtra("screenName",screenName);
        setResult(RESULT_OK, intent);
    }
}// end NameActivity class