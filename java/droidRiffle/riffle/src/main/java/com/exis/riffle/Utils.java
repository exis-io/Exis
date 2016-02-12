package com.exis.riffle;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.List;
import java.util.Random;

import go.mantle.Mantle;

public class Utils {
    private static Random generator = new Random();
    private static Gson gson = new GsonBuilder().create();


    /* Generate a random positive integer */
    static int newID() {
        return generator.nextInt(Integer.MAX_VALUE);
    }

    /**
     * Marshall the given arguments, preparing them for transmission to the core.
     * @return
     */
    static String marshall(Object[] args) {
        return gson.toJson(args);
    }

    static Object[] unmarshall(String json) {
//        Object[] result = gson.fromJson(json, Object[].class);
//        Riffle.debug("Json from core: " + json + " after: " + result.toString());
        return gson.fromJson(json, Object[].class);
    }
}

