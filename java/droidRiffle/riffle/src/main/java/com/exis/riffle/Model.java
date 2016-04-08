package com.exis.riffle;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by damouse on 1/23/16.
 */
public class Model {

    public final static Object[] representation() {
        List<Object> ret = new ArrayList();

//        for (Class c : classes) {
//            if (c == Integer.class)
//                ret.add("int");
//            else if (c == Boolean.class)
//                ret.add("bool");
//            else if (c == String.class)
//                ret.add("str");
//            else if (c == Float.class)
//                ret.add("float");
//            else if (c == Double.class)
//                ret.add("double");
//            else if (Model.class.isAssignableFrom(c)) {
//
//            } else {
//                Riffle.warn("Class " + c  + "has no ");
//            }
//        }

        return ret.toArray();
    }
}
