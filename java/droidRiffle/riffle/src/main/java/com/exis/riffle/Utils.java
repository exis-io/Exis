package com.exis.riffle;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.math.BigInteger;
import java.util.List;
import java.util.Random;

import go.mantle.Mantle;

public class Utils {
    private static Random generator = new Random();
    private static Gson gson = new GsonBuilder().create();

    static BigInteger newID() {
        return new BigInteger(53, generator);
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

    static BigInteger convertCoreInt64(Object o) {
        //Riffle.debug("Converting object: " + o.toString() + " Cast as double: " + t + " long value: " + t.longValue() + " BigInt: " + BigInteger.valueOf(t.longValue()).toString());
        BigInteger id = BigInteger.valueOf(((Double) o).longValue());
        return id;
    }
}
