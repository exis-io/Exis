package com.exis.riffle;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.Random;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/24/2016.
 */
public class Riffle {

    /* Public utilities */
    public static void setLogLevelOff() {
        Mantle.SetLogLevelOff();
    }

    public static void setLogLevelApp() {
        Mantle.SetLogLevelApp();
    }

    public static void setLogLevelErr() {
        Mantle.SetLogLevelErr();
    }

    public static void setLogLevelWarn() {
        Mantle.SetLogLevelWarn();
    }

    public static void setLogLevelInfo() {
        Mantle.SetLogLevelInfo();
    }

    public static void setLogLevelDebug() {
        Mantle.SetLogLevelDebug();
    }

    public static void setFabricDev() {
        Mantle.SetFabricDev();
    }

    public static void setFabricSandbox() {
        Mantle.SetFabricSandbox();
    }

    public static void setFabricProduction() {
        Mantle.SetFabricProduction();
    }

    public static void setFabricLocal() {
        Mantle.SetFabricLocal();
    }

    public static void setFabric(String url) {
        Mantle.SetFabric(url);
    }

    public static void application(String message) {
        Mantle.Application(message);
    }

    public static void debug(String message) {
        Mantle.Debug(message);
    }

    public static void info(String message) {
        Mantle.Info(message);
    }

    public static void warn(String message) {
        Mantle.Warn(message);
    }

    public static void error(String message) {
        Mantle.Error(message);
    }

    public static void setCuminStrict() { Mantle.SetCuminStrict(); }
    public static void setCuminLoose() { Mantle.SetCuminLoose(); }
    public static void setCuminOff() { Mantle.SetCuminOff(); }
}

