# droidRiffle

Riffle for Andorid. 

To install Riffle, add the following to your `build.gradle`.

```
compile 'com.exis.riffle:riffle:0.2.44'
```

Subscribe to an endpoint with a lambda: 

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

Publish to an endpoint:

        parent.receiver2.publish("sub", 1);

Publishing model objects: 

        parent.receiver2.publish("subscribeModels", new Dog());

Calling a function:

        parent.receiver2.call("reg", "Johnathan").then(String.class, (greeting) -> {
            Log.d(TAG, "I received : " + greeting);
        });

## Updating the Library

The library is uploaded through bintray.com. Update your `local.properties` with account credentials (as @damouse), update the version number in `riffle/build.gradle`, and make sure the project builds with `./gradlew install`. Finally, upload with `gradlew bintrayUpload`.