package com.exis.androidriffle;

import go.mantle.Mantle;

/**
 * Created by damouse on 1/23/16.
 *
 * See here for distribution: http://inthecheesefactory.com/blog/how-to-upload-library-to-jcenter-maven-central-as-dependency/en
 */
public class Domain {
    public static String hello() {
        Mantle.Hello();
        return "Done!";
    }
}
