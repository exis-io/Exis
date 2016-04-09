# droidRiffle

Riffle for Android. Please see our documentation at [exis.io](http://docs.exis.io). 

`droidAndroid` is in an experimental state. The following features are in progress:

- Backend support
- Model object serialization
- Not all `cuminication`, or type checking, in place

To install Riffle, add the following to your `build.gradle`.

```
compile 'com.exis.riffle:riffle:0.2.44'
```

Riffle is built around the *Deferred*, a programming tool that makes it easy to write code that executes out of order. This is called **asynchronous programming.** In Java, the result of operations are generally typed as anonymous handler overides. In Riffle we use Lambdas. 

Here's a more traditional handler written in Java. 

```
client.GET("users/", 1, 2, 3, new ResultHandler<String, Int>() {
    @Override
    public void onResult<String, Int>(String a, Int b) {
        Log.d(TAG, "Success : " + a + b);
    }

    @Override
    public void onFailure<String>(String error) {
        Log.d(TAG, "Failure : " + error);
    }
    });
```

Shorter is better, in our opinion. A *lambda* is a quick little anonymous function that isnt an object. 

```
// This isnt a class you *have* to write-- imagine it as some part of your application cde
class SomeRandomClass {
    ...

    public static void onResult(String a, Int b) {
        Log.d(TAG, "Success : " + a + b);
    }
}

// A pointer to the static function
client.GET("users/", 1, 2, 3, SomeRandomClass::onResult);

// An anonymous function that doesn't belong to anyone
client.GET("users/", 1, 2, 3, (a, b) -> {
    Log.d(TAG, "Success : " + a + b);
});
```

We took care of the implementation of lambdas, dont worry-- but Java 8 is required! [Download it here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).

## Using Riffle

Subscribe to an endpoint with a lambda. Note that you have to `Integer.class` to tell the system what kind of types you're expecting.

        subscribe("sub", Integer.class, (a) -> {
            Log.d(TAG, "I have a publish: " + a);
        });

Subscribe to an endpoint with a function pointer. 

        subscribe("vich", Boolean.class, this::someHandler);

Register a function. Note the return type.

        register("reg", String.class, String.class, (name) -> {
            Log.d(TAG, "I have a call from: " + name);
            return "Hey. caller!";
        });

Publish to an endpoint. You can pass any arguments as long as they can be converted to JSON. This means Strings, Integers, Booleans, Floats, Doubles, Arrays, and Maps (as well as their primitive types: int, boolean, float, etc.)

        parent.receiver2.publish("sub", 1);

Publishing model objects.

        // Any class that subclasses Riffle.Model can automatically be transmitted
        class Dog extends Riffle.Model {
            int age = 1;
            String name = "Fido";
            ...
        }
        parent.receiver2.publish("subscribeModels", new Dog());

Calling a function:

        parent.receiver2.call("reg", "Johnathan").then(String.class, (greeting) -> {
            Log.d(TAG, "I received : " + greeting);
        });

## Updating the Library

The library is uploaded through bintray.com. Update your `local.properties` with account credentials (as @damouse), update the version number in `riffle/build.gradle`, and make sure the project builds with `./gradlew install`. Finally, upload with `gradlew bintrayUpload`.