package com.exis.riffle.cumin;

import com.exis.riffle.Model;
import com.exis.riffle.Riffle;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.internal.LinkedTreeMap;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by damouse on 2/11/2016.
 */
public class Cumin {
	private static Gson gson = new GsonBuilder().create();

	// The final state of Cuminicated methods. These are ready to fire as needed
	public interface Wrapped {
		Object invoke(Object... args);
	}
	

	/**
	 * Converts arbitrary object b to be of type A. Constructs the type if needed.
	 */
	static <A> A convert(Class<A> a, Object b) {
		if (a.isInstance(b))
			return a.cast(b);

		// TODO: refactor and use GSON all the time
		// TODO: fails on empty strings, and dosent serialize null fields
		if (b instanceof LinkedTreeMap) {
			LinkedTreeMap map = (LinkedTreeMap) b;
			String json = map.toString();
			A result = gson.fromJson(json, a);
			return result;
		}

		//Riffle.info("Have object: " + b.getClass().toString());

		if (a == Integer.class) {
			if (b instanceof Double) {
				return (A) Integer.valueOf(((Double) b).intValue());
			}
		}

		Riffle.error("PRIMITIVE CONVERSTION FALLTHROUGH. Want: " + a.toString() + ", received: " + b.getClass() + ", value: " + b.toString());
		return null;
	}


	/**
	 * Return the representation of the class objects in a format suitable for Cumin in the core.
	 *
	 */
	public static Object[] representation(Class<?>... classes) {
		List<Object> ret = new ArrayList();

		for (Class c : classes) {
			Object repr = singleRepresentation(c);

			if (repr != null) {
				ret.add(repr);
			}
		}

		return ret.toArray();
	}

	// TODO: merge this into the above method, and only return the array if there's more than a single item
	public static Object singleRepresentation(Class<?> c) {
		if (c == Integer.class || c == int.class)
			return "int";
		else if (c == Boolean.class || c == boolean.class)
			return "bool";
		else if (c == String.class)
			return "str";
		else if (c == Float.class || c == float.class)
			return "float";
		else if (c == Double.class || c == double.class)
			return "double";
		else if (Model.class.isAssignableFrom(c)) {
			try {

				Method m = c.getMethod("representation", Class.class);
				Object r = m.invoke(null, c);
				return r;
			} catch (NoSuchMethodException e) {
				e.printStackTrace();
			} catch (InvocationTargetException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			}
		} else {
			// TODO: throw an exception and fail the domain operation
			Riffle.error("Class " + c  + " is not a valid type for handler!");
		}

		return null;
	}

	//
	//
	// Start Generic Shotgun

public static  Wrapped cuminicate(Handler.ZeroZero fn) {
    return (q) -> { fn.run(); return null; };
}

public static <A> Wrapped cuminicate(Class<A> a, Handler.OneZero<A> fn) {
    return (q) -> { fn.run(convert(a, q[0])); return null; };
}

public static <A, B> Wrapped cuminicate(Class<A> a, Class<B> b, Handler.TwoZero<A, B> fn) {
    return (q) -> { fn.run(convert(a, q[0]), convert(b, q[1])); return null; };
}

public static <A, B, C> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Handler.ThreeZero<A, B, C> fn) {
    return (q) -> { fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2])); return null; };
}

public static <A, B, C, D> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<D> d, Handler.FourZero<A, B, C, D> fn) {
    return (q) -> { fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2]), convert(d, q[3])); return null; };
}

public static <A, B, C, D, E> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Handler.FiveZero<A, B, C, D, E> fn) {
    return (q) -> { fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2]), convert(d, q[3]), convert(e, q[4])); return null; };
}

public static <A, B, C, D, E, F> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<F> f, Handler.SixZero<A, B, C, D, E, F> fn) {
    return (q) -> { fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2]), convert(d, q[3]), convert(e, q[4]), convert(f, q[5])); return null; };
}

public static <R> Wrapped cuminicate(Class<R> r, Handler.ZeroOne<R> fn) {
    return (q) -> { return fn.run(); };
}

public static <A, R> Wrapped cuminicate(Class<A> a, Class<R> r, Handler.OneOne<A, R> fn) {
    return (q) -> { return fn.run(convert(a, q[0])); };
}

public static <A, B, R> Wrapped cuminicate(Class<A> a, Class<B> b, Class<R> r, Handler.TwoOne<A, B, R> fn) {
    return (q) -> { return fn.run(convert(a, q[0]), convert(b, q[1])); };
}

public static <A, B, C, R> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<R> r, Handler.ThreeOne<A, B, C, R> fn) {
    return (q) -> { return fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2])); };
}

public static <A, B, C, D, R> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<R> r, Handler.FourOne<A, B, C, D, R> fn) {
    return (q) -> { return fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2]), convert(d, q[3])); };
}

public static <A, B, C, D, E, R> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<R> r, Handler.FiveOne<A, B, C, D, E, R> fn) {
    return (q) -> { return fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2]), convert(d, q[3]), convert(e, q[4])); };
}

public static <A, B, C, D, E, F, R> Wrapped cuminicate(Class<A> a, Class<B> b, Class<C> c, Class<D> d, Class<E> e, Class<F> f, Class<R> r, Handler.SixOne<A, B, C, D, E, F, R> fn) {
    return (q) -> { return fn.run(convert(a, q[0]), convert(b, q[1]), convert(c, q[2]), convert(d, q[3]), convert(e, q[4]), convert(f, q[5])); };
}
	// End Generic Shotgun
}
