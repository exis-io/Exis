package com.exis.riffle;

import com.exis.riffle.cumin.Cumin;
import com.google.gson.Gson;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by damouse on 1/23/16.
 */
public class Model {

    /**
     * Required no-args constructor to allow reflection of fields for Cumin through GSON
     */
    public Model() {

    }

    public final static <T extends Model> Map<String, Object> representation(Class<T> klass) {
        Map<String, Object> fields = new HashMap();

        for (Field f : klass.getDeclaredFields())  {
            Riffle.info("Field type: " + f.getType());
            Riffle.info("Field: " + f.toString());
            fields.put(f.getName(), Cumin.singleRepresentation(f.getType()));
        }

        return fields;
    }
}
