package com.exis.riffle;

import go.mantle.Mantle;

public class Utils {
    public static void SetLogLevelOff() {
        Mantle.SetLogLevelOff();
    }

    public static void SetLogLevelApp() {
        Mantle.SetLogLevelApp();
    }

    public static void SetLogLevelErr() {
        Mantle.SetLogLevelErr();
    }

    public static void SetLogLevelWarn() {
        Mantle.SetLogLevelWarn();
    }

    public static void SetLogLevelInfo() {
        Mantle.SetLogLevelInfo();
    }

    public static void SetLogLevelDebug() {
        Mantle.SetLogLevelDebug();
        ;
    }

    public static void SetFabricDev() {
        Mantle.SetFabricDev();
    }

    public static void SetFabricSandbox() {
        Mantle.SetFabricSandbox();
    }

    public static void SetFabricProduction() {
        Mantle.SetFabricProduction();
    }

    public static void SetFabricLocal() {
        Mantle.SetFabricLocal();
    }

    public static void SetFabric(String url) {
        Mantle.SetFabric(url);
    }

    public static void Application(String message) {
        Mantle.Application(message);
    }

    public static void Debug(String message) {
        Mantle.Debug(message);
    }

    public static void Info(String message) {
        Mantle.Info(message);
    }

    public static void Warn(String message) {
        Mantle.Warn(message);
    }

    public static void Error(String message) {
        Mantle.Error(message);
    }
}

