package com.markmuwonge.hello_world;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
public class MainActivity extends Activity{
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        TextView label = new TextView(this);
        label.setText("Hola Mundo!");

        setContentView(label);
    }
}

