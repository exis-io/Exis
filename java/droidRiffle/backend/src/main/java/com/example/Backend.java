package com.example;

//import com.exis.droidriffle.Model;

/** Getting builds from the command line

 Make sure the gradle wrapper exists: 'gradle wrapper' at root
 Create a new module as a java library
 Apply plugin "application" and set the main class
 Run ./gradlew run -p [MODULENAME]

 Optional note: to import model objects to both sides, put them in the backend! Cant import
 the android app into the backend
 */

public class Backend {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
//        System.out.println(Model.importer());
    }
}
