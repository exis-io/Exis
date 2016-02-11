package com.exis.riffle;

import java.io.File;

/**
 * Created by damouse on 2/11/16.
 */
public class Native {
    public static void main(String[] args) {
        System.out.println("Hello!");

        String targetPath = "/home/damouse/code/merged/riffle/java/droidRiffle/mantle/shh/jni/x86";

        String path=System.getProperty("java.library.path");
        System.out.println("\n\n\t java.library.path = "+path);

        System.setProperty("java.library.path", path + ":" + targetPath);

        path=System.getProperty("java.library.path");;
        System.out.println("\n\n\t java.library.path = " + path);;

        File folder = new File(targetPath);
        File[] listOfFiles = folder.listFiles();

        for (int i = 0; i < listOfFiles.length; i++) {
            if (listOfFiles[i].isFile()) {
                System.out.println("File " + listOfFiles[i].getName());
            } else if (listOfFiles[i].isDirectory()) {
                System.out.println("Directory " + listOfFiles[i].getName());
            }
        }

        Domain d = new Domain("xs.damouse");
    }
}
